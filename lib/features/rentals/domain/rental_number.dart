String formatRentalNumber(int number) =>
    'R-${number.toString().padLeft(4, '0')}';
