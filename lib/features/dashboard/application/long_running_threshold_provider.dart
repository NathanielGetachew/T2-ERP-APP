import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

const defaultLongRunningThresholdDays = 14;

final longRunningThresholdProvider =
    NotifierProvider<LongRunningThresholdNotifier, int>(
      LongRunningThresholdNotifier.new,
    );

class LongRunningThresholdNotifier extends Notifier<int> {
  @override
  int build() {
    unawaited(_load());
    return defaultLongRunningThresholdDays;
  }

  Future<void> setThreshold(int days) async {
    if (days < 1 || days > 365) {
      throw ArgumentError.value(
        days,
        'days',
        'Threshold must be between 1 and 365',
      );
    }
    state = days;
    try {
      final directory = await getApplicationDocumentsDirectory();
      await File('${directory.path}/long_running_threshold.txt')
          .writeAsString(days.toString());
    } catch (_) {
      // Ignore disk error in tests
    }
  }

  Future<void> _load() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/long_running_threshold.txt');
      if (!file.existsSync()) return;
      final content = (await file.readAsString()).trim();
      final parsed = int.tryParse(content);
      if (parsed != null && parsed >= 1 && parsed <= 365) {
        state = parsed;
      }
    } catch (_) {
      // Ignore disk error in tests
    }
  }
}
