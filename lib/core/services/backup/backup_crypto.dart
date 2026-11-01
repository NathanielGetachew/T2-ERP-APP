import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

const backupMagic = <int>[0x54, 0x32, 0x42, 0x4b]; // T2BK
const backupFormatVersion = 1;
const backupKdfIterations = 210000;
const defaultBackupChunkSize = 1024 * 1024;

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WrongPasswordOrCorruptedBackup implements Exception {
  const WrongPasswordOrCorruptedBackup();

  @override
  String toString() =>
      'The password is wrong or the backup is corrupted; authenticated encryption cannot distinguish these cases.';
}

class UnsupportedBackupException implements Exception {
  const UnsupportedBackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<void> encryptBackupFile({
  required File input,
  required File output,
  required String password,
  int chunkSize = defaultBackupChunkSize,
}) => Isolate.run(
  () => _encryptBackupFile(
    inputPath: input.path,
    outputPath: output.path,
    password: password,
    chunkSize: chunkSize,
  ),
);

Future<void> decryptBackupFile({
  required File input,
  required File output,
  required String password,
  int chunkSize = defaultBackupChunkSize,
}) => Isolate.run(
  () => _decryptBackupFile(
    inputPath: input.path,
    outputPath: output.path,
    password: password,
    chunkSize: chunkSize,
  ),
);

Future<void> _encryptBackupFile({
  required String inputPath,
  required String outputPath,
  required String password,
  required int chunkSize,
}) async {
  final input = await File(inputPath).open();
  final output = await File(outputPath).open(mode: FileMode.write);
  final salt = _randomBytes(16);
  final key = await _deriveKey(password, salt);
  try {
    await output.writeFrom(backupMagic);
    await output.writeByte(backupFormatVersion);
    await output.writeFrom(_u32(backupKdfIterations));
    await output.writeFrom(salt);
    var index = 0;
    while (true) {
      final chunk = await input.read(chunkSize);
      if (chunk.isEmpty) break;
      final next = await input.read(1);
      final isFinal = next.isEmpty;
      if (next.isNotEmpty) {
        await input.setPosition(await input.position() - 1);
      }
      final aad = _aad(index, isFinal);
      final nonce = _randomBytes(12);
      final box = await AesGcm.with256bits().encrypt(
        chunk,
        secretKey: key,
        nonce: nonce,
        aad: aad,
      );
      final payload = <int>[...box.cipherText, ...box.mac.bytes];
      await output.writeFrom(_u32(index));
      await output.writeByte(isFinal ? 1 : 0);
      await output.writeFrom(_u32(payload.length));
      await output.writeFrom(nonce);
      await output.writeFrom(payload);
      index++;
      if (isFinal) break;
    }
    if (index == 0) {
      final aad = _aad(0, true);
      final nonce = _randomBytes(12);
      final box = await AesGcm.with256bits().encrypt(
        const [],
        secretKey: key,
        nonce: nonce,
        aad: aad,
      );
      final payload = <int>[...box.cipherText, ...box.mac.bytes];
      await output.writeFrom(_u32(0));
      await output.writeByte(1);
      await output.writeFrom(_u32(payload.length));
      await output.writeFrom(nonce);
      await output.writeFrom(payload);
    }
  } finally {
    await input.close();
    await output.close();
  }
}

Future<void> _decryptBackupFile({
  required String inputPath,
  required String outputPath,
  required String password,
  required int chunkSize,
}) async {
  final input = await File(inputPath).open();
  final output = await File(outputPath).open(mode: FileMode.write);
  try {
    final magic = await _readExactly(input, 4);
    if (!_sameBytes(magic, backupMagic)) {
      throw const BackupFormatException('This is not a T2 Rental backup.');
    }
    final version = (await _readExactly(input, 1)).single;
    if (version > backupFormatVersion) {
      throw const UnsupportedBackupException(
        'This backup requires a newer version of the app. Please update the app first.',
      );
    }
    final iterations = _readU32(await _readExactly(input, 4));
    final salt = await _readExactly(input, 16);
    final key = await _deriveKey(password, salt, iterations: iterations);
    var expectedIndex = 0;
    var sawFinal = false;
    while (true) {
      final indexBytes = await _readMaybe(input, 4);
      if (indexBytes == null) break;
      final index = _readU32(indexBytes);
      final isFinal = (await _readExactly(input, 1)).single == 1;
      final length = _readU32(await _readExactly(input, 4));
      final nonce = await _readExactly(input, 12);
      final payload = await _readExactly(input, length);
      if (index != expectedIndex || length < 16 || sawFinal) {
        throw const WrongPasswordOrCorruptedBackup();
      }
      try {
        final plain = await AesGcm.with256bits().decrypt(
          SecretBox(
            payload.sublist(0, payload.length - 16),
            nonce: nonce,
            mac: Mac(payload.sublist(payload.length - 16)),
          ),
          secretKey: key,
          aad: _aad(index, isFinal),
        );
        await output.writeFrom(plain);
      } on SecretBoxAuthenticationError {
        throw const WrongPasswordOrCorruptedBackup();
      } catch (error) {
        if (error is WrongPasswordOrCorruptedBackup) rethrow;
        throw const WrongPasswordOrCorruptedBackup();
      }
      expectedIndex++;
      if (isFinal) {
        sawFinal = true;
        break;
      }
    }
    if (!sawFinal || (await input.read(1)).isNotEmpty) {
      throw const WrongPasswordOrCorruptedBackup();
    }
  } finally {
    await input.close();
    await output.close();
  }
}

Future<SecretKey> _deriveKey(
  String password,
  List<int> salt, {
  int iterations = backupKdfIterations,
}) => Pbkdf2(
  macAlgorithm: Hmac.sha256(),
  iterations: iterations,
  bits: 256,
).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);

List<int> _aad(int index, bool isFinal) => [
  ...backupMagic,
  backupFormatVersion,
  ..._u32(index),
  isFinal ? 1 : 0,
];

List<int> _randomBytes(int length) =>
    List<int>.generate(length, (_) => Random.secure().nextInt(256));

List<int> _u32(int value) => [
  (value >> 24) & 0xff,
  (value >> 16) & 0xff,
  (value >> 8) & 0xff,
  value & 0xff,
];

int _readU32(List<int> bytes) =>
    (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];

Future<List<int>> _readExactly(RandomAccessFile file, int length) async {
  final bytes = await file.read(length);
  if (bytes.length != length) {
    throw const WrongPasswordOrCorruptedBackup();
  }
  return bytes;
}

Future<List<int>?> _readMaybe(RandomAccessFile file, int length) async {
  final bytes = await file.read(length);
  if (bytes.isEmpty) return null;
  if (bytes.length != length) {
    throw const WrongPasswordOrCorruptedBackup();
  }
  return bytes;
}

bool _sameBytes(List<int> first, List<int> second) =>
    first.length == second.length &&
    first.asMap().entries.every((entry) => entry.value == second[entry.key]);
