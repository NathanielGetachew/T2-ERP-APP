class MoneyInputException extends FormatException {
  const MoneyInputException(super.message);
}

int parseEtbMinorUnits(String input) {
  final value = input.trim();
  final match = RegExp(r'^(0|[1-9][0-9]*)(?:\.([0-9]{1,2}))?$')
      .firstMatch(value);
  if (match == null) {
    throw const MoneyInputException(
      'Enter a valid non-negative amount with up to two decimals.',
    );
  }
  final whole = int.parse(match.group(1)!);
  final decimals = (match.group(2) ?? '').padRight(2, '0');
  return whole * 100 + (decimals.isEmpty ? 0 : int.parse(decimals));
}
