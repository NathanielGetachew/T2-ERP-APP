String formatEtb(int minorUnits, {String suffix = ' ETB'}) {
  final sign = minorUnits < 0 ? '-' : '';
  final absolute = minorUnits.abs();
  final birr = absolute ~/ 100;
  final santim = (absolute % 100).toString().padLeft(2, '0');

  final birrDigits = birr.toString();
  final groupedBirr = StringBuffer();
  for (var index = 0; index < birrDigits.length; index++) {
    if (index > 0 && (birrDigits.length - index) % 3 == 0) {
      groupedBirr.write(',');
    }
    groupedBirr.write(birrDigits[index]);
  }

  return '$sign$groupedBirr.$santim$suffix';
}
