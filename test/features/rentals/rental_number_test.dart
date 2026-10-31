import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/features/rentals/domain/rental_number.dart';

void main() {
  test('formats rental numbers with an R prefix and four digits', () {
    expect(formatRentalNumber(1), 'R-0001');
    expect(formatRentalNumber(12345), 'R-12345');
  });
}
