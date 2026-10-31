import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/utils/money_parser.dart';

void main() {
  test('parses valid whole and decimal ETB amounts', () {
    expect(parseEtbMinorUnits('250'), 25000);
    expect(parseEtbMinorUnits('250.5'), 25050);
    expect(parseEtbMinorUnits('250.50'), 25050);
    expect(parseEtbMinorUnits('0.01'), 1);
  });

  test('rejects invalid, negative, and over-precise values', () {
    for (final value in ['', '-1', '1.234', '1.', '.50', 'abc', '1,000']) {
      expect(
        () => parseEtbMinorUnits(value),
        throwsA(isA<MoneyInputException>()),
      );
    }
  });
}
