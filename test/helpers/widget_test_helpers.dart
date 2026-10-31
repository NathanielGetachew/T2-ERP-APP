import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}
