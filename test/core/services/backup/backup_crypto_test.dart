import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/services/backup/backup_crypto.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('t2-backup-crypto-test-');
  });

  tearDown(() => directory.delete(recursive: true));

  test('encrypts and decrypts a multi-chunk payload', () async {
    final source = File('${directory.path}${Platform.pathSeparator}source.bin');
    final encrypted = File(
      '${directory.path}${Platform.pathSeparator}backup.t2backup',
    );
    final restored = File(
      '${directory.path}${Platform.pathSeparator}restored.bin',
    );
    final bytes = List<int>.generate(37, (index) => index * 7 % 256);
    await source.writeAsBytes(bytes);

    await encryptBackupFile(
      input: source,
      output: encrypted,
      password: 'correct horse',
      chunkSize: 5,
    );
    await decryptBackupFile(
      input: encrypted,
      output: restored,
      password: 'correct horse',
      chunkSize: 5,
    );

    expect(await restored.readAsBytes(), bytes);
  });

  test('rejects wrong password', () async {
    final source = File('${directory.path}${Platform.pathSeparator}source.bin');
    final encrypted = File(
      '${directory.path}${Platform.pathSeparator}backup.t2backup',
    );
    final output = File('${directory.path}${Platform.pathSeparator}output.bin');
    await source.writeAsBytes(List<int>.generate(25, (index) => index));
    await encryptBackupFile(
      input: source,
      output: encrypted,
      password: 'correct horse',
      chunkSize: 10,
    );

    expect(
      decryptBackupFile(
        input: encrypted,
        output: output,
        password: 'wrong password',
        chunkSize: 10,
      ),
      throwsA(isA<WrongPasswordOrCorruptedBackup>()),
    );
  });

  test('rejects flipped byte in header (magic and salt)', () async {
    final source = File('${directory.path}${Platform.pathSeparator}source.bin');
    final encrypted = File(
      '${directory.path}${Platform.pathSeparator}backup.t2backup',
    );
    final output = File('${directory.path}${Platform.pathSeparator}output.bin');
    await source.writeAsBytes(List<int>.generate(25, (index) => index));
    await encryptBackupFile(
      input: source,
      output: encrypted,
      password: 'correct horse',
      chunkSize: 10,
    );
    final originalBytes = await encrypted.readAsBytes();

    // Flip byte in magic (offset 0..3)
    final flippedMagic = File(
      '${directory.path}${Platform.pathSeparator}flipped_magic.t2backup',
    );
    final magicBytes = List<int>.from(originalBytes);
    magicBytes[0] ^= 0xFF;
    await flippedMagic.writeAsBytes(magicBytes);
    expect(
      decryptBackupFile(
        input: flippedMagic,
        output: output,
        password: 'correct horse',
        chunkSize: 10,
      ),
      throwsA(isA<BackupFormatException>()),
    );

    // Flip byte in salt (offset 9..24)
    final flippedSalt = File(
      '${directory.path}${Platform.pathSeparator}flipped_salt.t2backup',
    );
    final saltBytes = List<int>.from(originalBytes);
    saltBytes[15] ^= 0x01;
    await flippedSalt.writeAsBytes(saltBytes);
    expect(
      decryptBackupFile(
        input: flippedSalt,
        output: output,
        password: 'correct horse',
        chunkSize: 10,
      ),
      throwsA(isA<WrongPasswordOrCorruptedBackup>()),
    );
  });

  test('rejects flipped byte in middle chunk and last chunk', () async {
    final source = File('${directory.path}${Platform.pathSeparator}source.bin');
    final encrypted = File(
      '${directory.path}${Platform.pathSeparator}backup.t2backup',
    );
    final output = File('${directory.path}${Platform.pathSeparator}output.bin');
    // 25 bytes with chunkSize 10 creates 3 chunks: chunk 0 (10B), chunk 1 (10B), chunk 2 (5B)
    await source.writeAsBytes(List<int>.generate(25, (index) => index));
    await encryptBackupFile(
      input: source,
      output: encrypted,
      password: 'correct horse',
      chunkSize: 10,
    );
    final originalBytes = await encrypted.readAsBytes();

    // Flip byte in middle chunk (chunk 1 starts around offset 72)
    final flippedMiddle = File(
      '${directory.path}${Platform.pathSeparator}flipped_middle.t2backup',
    );
    final middleBytes = List<int>.from(originalBytes);
    middleBytes[80] ^= 0x01;
    await flippedMiddle.writeAsBytes(middleBytes);
    expect(
      decryptBackupFile(
        input: flippedMiddle,
        output: output,
        password: 'correct horse',
        chunkSize: 10,
      ),
      throwsA(isA<WrongPasswordOrCorruptedBackup>()),
    );

    // Flip byte in last chunk (near end of file)
    final flippedLast = File(
      '${directory.path}${Platform.pathSeparator}flipped_last.t2backup',
    );
    final lastBytes = List<int>.from(originalBytes);
    lastBytes[lastBytes.length - 2] ^= 0x01;
    await flippedLast.writeAsBytes(lastBytes);
    expect(
      decryptBackupFile(
        input: flippedLast,
        output: output,
        password: 'correct horse',
        chunkSize: 10,
      ),
      throwsA(isA<WrongPasswordOrCorruptedBackup>()),
    );
  });

  test('rejects truncation in header and body', () async {
    final source = File('${directory.path}${Platform.pathSeparator}source.bin');
    final encrypted = File(
      '${directory.path}${Platform.pathSeparator}backup.t2backup',
    );
    final output = File('${directory.path}${Platform.pathSeparator}output.bin');
    await source.writeAsBytes(List<int>.generate(25, (index) => index));
    await encryptBackupFile(
      input: source,
      output: encrypted,
      password: 'correct horse',
      chunkSize: 10,
    );
    final originalBytes = await encrypted.readAsBytes();

    // Truncate inside header (< 25 bytes)
    final truncHeader = File(
      '${directory.path}${Platform.pathSeparator}trunc_header.t2backup',
    );
    await truncHeader.writeAsBytes(originalBytes.sublist(0, 12));
    expect(
      decryptBackupFile(
        input: truncHeader,
        output: output,
        password: 'correct horse',
        chunkSize: 10,
      ),
      throwsA(isA<WrongPasswordOrCorruptedBackup>()),
    );

    // Truncate inside body
    final truncBody = File(
      '${directory.path}${Platform.pathSeparator}trunc_body.t2backup',
    );
    await truncBody.writeAsBytes(
      originalBytes.sublist(0, originalBytes.length - 10),
    );
    expect(
      decryptBackupFile(
        input: truncBody,
        output: output,
        password: 'correct horse',
        chunkSize: 10,
      ),
      throwsA(isA<WrongPasswordOrCorruptedBackup>()),
    );
  });

  test('rejects reordered chunk records', () async {
    final source = File('${directory.path}${Platform.pathSeparator}source.bin');
    final encrypted = File(
      '${directory.path}${Platform.pathSeparator}backup.t2backup',
    );
    final reordered = File(
      '${directory.path}${Platform.pathSeparator}reordered.t2backup',
    );
    final output = File('${directory.path}${Platform.pathSeparator}output.bin');
    await source.writeAsBytes(List<int>.generate(20, (index) => index + 1));
    await encryptBackupFile(
      input: source,
      output: encrypted,
      password: 'correct horse',
      chunkSize: 4,
    );
    final bytes = await encrypted.readAsBytes();
    const headerLength = 25;
    final firstLength = 21 + _readU32(bytes, headerLength + 5);
    final secondStart = headerLength + firstLength;
    final secondLength = 21 + _readU32(bytes, secondStart + 5);
    final result = <int>[
      ...bytes.sublist(0, headerLength),
      ...bytes.sublist(secondStart, secondStart + secondLength),
      ...bytes.sublist(headerLength, headerLength + firstLength),
      ...bytes.sublist(secondStart + secondLength),
    ];
    await reordered.writeAsBytes(result);
    expect(
      decryptBackupFile(
        input: reordered,
        output: output,
        password: 'correct horse',
        chunkSize: 4,
      ),
      throwsA(isA<WrongPasswordOrCorruptedBackup>()),
    );
  });
}

int _readU32(List<int> bytes, int offset) =>
    (bytes[offset] << 24) |
    (bytes[offset + 1] << 16) |
    (bytes[offset + 2] << 8) |
    bytes[offset + 3];
