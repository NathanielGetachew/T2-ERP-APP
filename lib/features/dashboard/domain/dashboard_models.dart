enum DashboardPeriodType { thisMonth, lastMonth, last3Months, thisYear, custom }

enum MaterialRankingSort { unitDays, timesRented, totalQuantity }

class DashboardPeriod {
  const DashboardPeriod({
    required this.type,
    required this.startDateLocal,
    required this.endDateLocal,
  });

  final DashboardPeriodType type;

  /// Inclusive start date at local 00:00:00.000
  final DateTime startDateLocal;

  /// Inclusive end date at local 23:59:59.999
  final DateTime endDateLocal;

  DateTime get startDate => startDateLocal;
  DateTime get endDate => endDateLocal;

  factory DashboardPeriod.fromType(
    DashboardPeriodType type, {
    required DateTime now,
  }) {
    switch (type) {
      case DashboardPeriodType.thisMonth:
        return DashboardPeriod.thisMonth(now);
      case DashboardPeriodType.lastMonth:
        return DashboardPeriod.lastMonth(now);
      case DashboardPeriodType.last3Months:
        return DashboardPeriod.last3Months(now);
      case DashboardPeriodType.thisYear:
        return DashboardPeriod.thisYear(now);
      case DashboardPeriodType.custom:
        return DashboardPeriod.thisMonth(now);
    }
  }

  factory DashboardPeriod.thisMonth(DateTime nowLocal) {
    final start = DateTime.utc(nowLocal.year, nowLocal.month, 1);
    final nextMonth = nowLocal.month == 12
        ? DateTime.utc(nowLocal.year + 1, 1, 1)
        : DateTime.utc(nowLocal.year, nowLocal.month + 1, 1);
    final end = nextMonth.subtract(const Duration(milliseconds: 1));
    return DashboardPeriod(
      type: DashboardPeriodType.thisMonth,
      startDateLocal: start,
      endDateLocal: end,
    );
  }

  factory DashboardPeriod.lastMonth(DateTime nowLocal) {
    final prevYear = nowLocal.month == 1 ? nowLocal.year - 1 : nowLocal.year;
    final prevMonth = nowLocal.month == 1 ? 12 : nowLocal.month - 1;
    final start = DateTime.utc(prevYear, prevMonth, 1);
    final thisMonthStart = DateTime.utc(nowLocal.year, nowLocal.month, 1);
    final end = thisMonthStart.subtract(const Duration(milliseconds: 1));
    return DashboardPeriod(
      type: DashboardPeriodType.lastMonth,
      startDateLocal: start,
      endDateLocal: end,
    );
  }

  factory DashboardPeriod.last3Months(DateTime nowLocal) {
    // Current month plus 2 previous calendar months
    var year = nowLocal.year;
    var month = nowLocal.month - 2;
    while (month < 1) {
      month += 12;
      year -= 1;
    }
    final start = DateTime.utc(year, month, 1);
    final nextMonth = nowLocal.month == 12
        ? DateTime.utc(nowLocal.year + 1, 1, 1)
        : DateTime.utc(nowLocal.year, nowLocal.month + 1, 1);
    final end = nextMonth.subtract(const Duration(milliseconds: 1));
    return DashboardPeriod(
      type: DashboardPeriodType.last3Months,
      startDateLocal: start,
      endDateLocal: end,
    );
  }

  factory DashboardPeriod.thisYear(DateTime nowLocal) {
    final start = DateTime.utc(nowLocal.year, 1, 1);
    final end = DateTime.utc(nowLocal.year, 12, 31, 23, 59, 59, 999);
    return DashboardPeriod(
      type: DashboardPeriodType.thisYear,
      startDateLocal: start,
      endDateLocal: end,
    );
  }

  factory DashboardPeriod.custom(DateTime startLocal, DateTime endLocal) {
    final start = DateTime.utc(
      startLocal.year,
      startLocal.month,
      startLocal.day,
    );
    final end = DateTime.utc(
      endLocal.year,
      endLocal.month,
      endLocal.day,
      23,
      59,
      59,
      999,
    );
    if (end.isBefore(start)) {
      throw ArgumentError('endLocal must be on or after startLocal');
    }
    return DashboardPeriod(
      type: DashboardPeriodType.custom,
      startDateLocal: start,
      endDateLocal: end,
    );
  }

  bool containsLocalDate(DateTime localDate) {
    final normalized = localDate.isUtc
        ? localDate
        : DateTime.utc(
            localDate.year,
            localDate.month,
            localDate.day,
            localDate.hour,
            localDate.minute,
            localDate.second,
            localDate.millisecond,
          );
    return !normalized.isBefore(startDateLocal) &&
        !normalized.isAfter(endDateLocal);
  }

  bool containsUtcDate(DateTime utcDate, Duration localOffset) {
    final shifted = utcDate.toUtc().add(localOffset);
    final local = DateTime.utc(
      shifted.year,
      shifted.month,
      shifted.day,
      shifted.hour,
      shifted.minute,
      shifted.second,
      shifted.millisecond,
    );
    return containsLocalDate(local);
  }
}

class MonthRevenueMetric {
  const MonthRevenueMetric({
    required this.year,
    required this.month,
    required this.amount,
    this.percentChange,
    this.previousMonthRevenueMinorUnits = 0,
  });

  final int year;
  final int month;
  final int amount; // integer minor units
  final double? percentChange;
  final int previousMonthRevenueMinorUnits;

  int get revenueMinorUnits => amount;
}

class MonthDurationMetric {
  const MonthDurationMetric({
    required this.year,
    required this.month,
    required this.averageDays,
  });

  final int year;
  final int month;
  final double? averageDays;

  double? get averageDurationDays => averageDays;
}

class MaterialRentalMetric {
  const MaterialRentalMetric({
    required this.materialId,
    required this.materialName,
    required this.category,
    required this.unitDays,
    required this.timesRented,
    required this.totalQuantity,
  });

  final String materialId;
  final String materialName;
  final String category;
  final int unitDays;
  final int timesRented;
  final int totalQuantity;

  String get name => materialName;
}

class MaterialStockOutMetric {
  const MaterialStockOutMetric({
    required this.materialId,
    required this.materialName,
    required this.category,
    required this.unitsOut,
    this.totalStock,
  });

  final String materialId;
  final String materialName;
  final String category;
  final int unitsOut;
  final int? totalStock;

  String get name => materialName;
  int get quantityOut => unitsOut;
}

class CustomerRankMetric {
  const CustomerRankMetric({
    required this.customerId,
    required this.customerName,
    required this.earnedRevenue,
    required this.rentalsCount,
    this.phone,
  });

  final String customerId;
  final String customerName;
  final int earnedRevenue;
  final int rentalsCount;
  final String? phone;

  int get totalRevenueMinorUnits => earnedRevenue;
  int get rentalCount => rentalsCount;
  String get customerPhone => phone ?? '';
}

class LongRunningRentalMetric {
  const LongRunningRentalMetric({
    required this.rentalId,
    required this.rentalNumber,
    required this.customerId,
    required this.customerName,
    required this.rentedAtUtc,
    required this.daysSoFar,
    required this.itemsSummary,
  });

  final String rentalId;
  final int rentalNumber;
  final String customerId;
  final String customerName;
  final DateTime rentedAtUtc;
  final int daysSoFar;
  final String itemsSummary;

  DateTime get rentedAt => rentedAtUtc;
}

class DashboardMetrics {
  const DashboardMetrics({
    required this.period,
    required this.periodEarnedRevenue,
    required this.monthlyRevenueChart,
    required this.previousMonthRevenue,
    required this.monthOverMonthChangePercent,
    required this.averageDurationDays,
    required this.durationMonthlyTrend,
    required this.mostRentedMaterials,
    required this.activeRentalsCount,
    required this.materialsCurrentlyOut,
    required this.longRunningRentals,
    required this.longRunningThresholdDays,
    required this.newCustomersCount,
    required this.returningCustomersCount,
    required this.topCustomersByRevenue,
    required this.topCustomersByRentals,
    required this.outstandingEstimate,
  });

  final DashboardPeriod period;
  final int periodEarnedRevenue;
  final List<MonthRevenueMetric> monthlyRevenueChart; // last 12 months
  final int previousMonthRevenue;
  final double? monthOverMonthChangePercent;

  final double? averageDurationDays; // null if no completed rentals in period
  final List<MonthDurationMetric> durationMonthlyTrend; // last 6 months

  final List<MaterialRentalMetric> mostRentedMaterials;

  final int activeRentalsCount;
  final List<MaterialStockOutMetric> materialsCurrentlyOut;
  final List<LongRunningRentalMetric> longRunningRentals;
  final int longRunningThresholdDays;

  final int newCustomersCount;
  final int returningCustomersCount;
  final List<CustomerRankMetric> topCustomersByRevenue;
  final List<CustomerRankMetric> topCustomersByRentals;

  final int outstandingEstimate;

  List<MonthRevenueMetric> get monthlyRevenue => monthlyRevenueChart;
  List<MonthDurationMetric> get durationTrend => durationMonthlyTrend;
  List<MaterialStockOutMetric> get materialsOut => materialsCurrentlyOut;
}
