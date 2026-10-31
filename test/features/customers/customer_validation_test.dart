import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/features/customers/domain/customer_validation.dart';

void main() {
  test(
    'normalizes customer text by trimming, lowercasing, and collapsing spaces',
    () {
      expect(normalizeCustomerText('  Abebe   Kebede '), 'abebe kebede');
    },
  );

  test('normalizes phone separators', () {
    expect(normalizeCustomerPhone(' +251 911-123456 '), '+251911123456');
  });

  test('validates optional phone characters and digit count', () {
    expect(validateCustomerPhone(null), isNull);
    expect(validateCustomerPhone('0911 123 456'), isNull);
    expect(validateCustomerPhone('+251-911-123456'), isNull);
    expect(validateCustomerPhone('123456'), isNotNull);
    expect(validateCustomerPhone('0911 ABC 456'), isNotNull);
    expect(validateCustomerPhone('1' * 16), isNotNull);
  });

  test('requires full name, address, and front photo', () {
    expect(validateCustomerFullName('  '), isNotNull);
    expect(validateCustomerAddress(''), isNotNull);
    expect(
      () => validateCustomer(
        fullName: 'Abebe',
        address: 'Addis Ababa',
        phone: null,
        idPhotoFrontPath: '',
      ),
      throwsA(isA<CustomerValidationException>()),
    );
  });
}
