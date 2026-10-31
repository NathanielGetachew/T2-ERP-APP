import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/utils/money.dart';

void main() {
  test('formats zero minor units', () {
    expect(formatEtb(0), '0.00 ETB');
  });

  test('formats values below one birr', () {
    expect(formatEtb(5), '0.05 ETB');
    expect(formatEtb(99), '0.99 ETB');
  });

  test('formats one birr and larger values', () {
    expect(formatEtb(100), '1.00 ETB');
    expect(formatEtb(123456), '1,234.56 ETB');
    expect(formatEtb(100000000), '1,000,000.00 ETB');
    expect(formatEtb(1000000001), '10,000,000.01 ETB');
  });

  test('formats negative values', () {
    expect(formatEtb(-125), '-1.25 ETB');
  });
}
