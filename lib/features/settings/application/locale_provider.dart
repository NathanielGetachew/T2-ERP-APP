import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    unawaited(_load());
    return null;
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final directory = await getApplicationDocumentsDirectory();
    await File('${directory.path}/locale.txt')
        .writeAsString(locale.languageCode);
  }

  Future<void> _load() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/locale.txt');
    if (!file.existsSync()) return;
    final code = (await file.readAsString()).trim();
    if (code == 'en' || code == 'am') state = Locale(code);
  }
}
