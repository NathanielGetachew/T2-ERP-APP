class CustomerValidationException implements Exception {
  const CustomerValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

String normalizeCustomerText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

String normalizeCustomerPhone(String value) {
  return value.trim().replaceAll(RegExp(r'[\s-]'), '');
}

String? validateCustomerFullName(String value) {
  return value.trim().isEmpty ? 'Name is required.' : null;
}

String? validateCustomerAddress(String value) {
  return value.trim().isEmpty ? 'Address is required.' : null;
}

String? validateCustomerPhone(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final normalized = normalizeCustomerPhone(value);
  if (!RegExp(r'^[0-9+\-]+$').hasMatch(normalized)) {
    return 'Phone may contain only digits, spaces, +, and -.';
  }
  final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length < 7 || digits.length > 15) {
    return 'Phone must contain 7 to 15 digits.';
  }
  return null;
}

void validateCustomer({
  required String fullName,
  required String address,
  required String? phone,
  required String idPhotoFrontPath,
}) {
  if (validateCustomerFullName(fullName) != null) {
    throw const CustomerValidationException('Name is required.');
  }
  if (validateCustomerAddress(address) != null) {
    throw const CustomerValidationException('Address is required.');
  }
  final phoneError = validateCustomerPhone(phone);
  if (phoneError != null) {
    throw CustomerValidationException(phoneError);
  }
  if (idPhotoFrontPath.trim().isEmpty) {
    throw const CustomerValidationException('Front ID photo is required.');
  }
}
