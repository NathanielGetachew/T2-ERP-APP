import '../../billing/rental_billing.dart';
import '../../customers/domain/customer.dart';
import '../../materials/domain/rental_material.dart';
import '../../rentals/domain/rental.dart';
import 'dashboard_models.dart';

DateTime toLocalDate(DateTime utc, Duration localOffset) {
  final shifted = utc.toUtc().add(localOffset);
  return DateTime.utc(
    shifted.year,
    shifted.month,
    shifted.day,
    shifted.hour,
    shifted.minute,
    shifted.second,
    shifted.millisecond,
  );
}

DashboardMetrics computeDashboardMetrics({
  required List<RentalRecord> rentals,
  required List<RentalLine> lines,
  required List<ReturnEventRecord> returnEvents,
  required List<Customer> customers,
  required List<RentalMaterial> materials,
  required DashboardPeriod period,
  required DateTime nowUtc,
  required Duration localOffset,
  required int longRunningThresholdDays,
}) {
  final nowLocal = toLocalDate(nowUtc, localOffset);

  // Filter out voided records
  final validRentals = rentals
      .where((r) => r.voidedAt == null && r.status != RentalStatus.voided)
      .toList();
  final validRentalIds = validRentals.map((r) => r.id).toSet();

  final validLines = lines
      .where((l) => validRentalIds.contains(l.rentalId))
      .toList();
  final linesByRentalId = <String, List<RentalLine>>{};
  for (final line in validLines) {
    linesByRentalId.putIfAbsent(line.rentalId, () => []).add(line);
  }

  final validReturnEvents = returnEvents
      .where((e) => e.voidedAt == null && validRentalIds.contains(e.rentalId))
      .toList();
  final returnEventsByRentalId = <String, List<ReturnEventRecord>>{};
  for (final event in validReturnEvents) {
    returnEventsByRentalId.putIfAbsent(event.rentalId, () => []).add(event);
  }

  final customerMap = {for (final c in customers) c.id: c};
  final materialMap = {for (final m in materials) m.id: m};

  // 1. Revenue
  var periodEarnedRevenue = 0;
  for (final event in validReturnEvents) {
    final eventLocalDate = toLocalDate(event.returnedAt, localOffset);
    if (period.containsLocalDate(eventLocalDate)) {
      periodEarnedRevenue += event.amount;
    }
  }

  // Monthly revenue chart: last 12 calendar months ending with current month
  // Precompute month 13 months ago so the 1st bar also has a previous month comparison
  var y0 = nowLocal.year;
  var m0 = nowLocal.month - 12;
  while (m0 < 1) {
    m0 += 12;
    y0 -= 1;
  }
  var prevMonthAmount = 0;
  for (final event in validReturnEvents) {
    final local = toLocalDate(event.returnedAt, localOffset);
    if (local.year == y0 && local.month == m0) {
      prevMonthAmount += event.amount;
    }
  }

  final monthlyRevenueChart = <MonthRevenueMetric>[];
  for (var i = 11; i >= 0; i--) {
    var year = nowLocal.year;
    var month = nowLocal.month - i;
    while (month < 1) {
      month += 12;
      year -= 1;
    }

    var monthAmount = 0;
    for (final event in validReturnEvents) {
      final local = toLocalDate(event.returnedAt, localOffset);
      if (local.year == year && local.month == month) {
        monthAmount += event.amount;
      }
    }
    final pct = computeMonthOverMonthPercent(
      current: monthAmount,
      previous: prevMonthAmount,
    );
    monthlyRevenueChart.add(
      MonthRevenueMetric(
        year: year,
        month: month,
        amount: monthAmount,
        previousMonthRevenueMinorUnits: prevMonthAmount,
        percentChange: pct,
      ),
    );
    prevMonthAmount = monthAmount;
  }

  final currentMonthRevenue = monthlyRevenueChart.last.amount;
  final previousMonthRevenue =
      monthlyRevenueChart[monthlyRevenueChart.length - 2].amount;
  final monthOverMonthChangePercent = computeMonthOverMonthPercent(
    current: currentMonthRevenue,
    previous: previousMonthRevenue,
  );

  // 2. Average rental duration for completed rentals whose final return falls in period
  final completedRentals = validRentals
      .where((r) => r.status == RentalStatus.returned)
      .toList();
  var durationSum = 0;
  var completedInPeriodCount = 0;

  for (final rental in completedRentals) {
    final events = returnEventsByRentalId[rental.id] ?? const [];
    if (events.isEmpty) continue;

    DateTime? latestReturnUtc;
    for (final event in events) {
      if (latestReturnUtc == null ||
          event.returnedAt.isAfter(latestReturnUtc)) {
        latestReturnUtc = event.returnedAt;
      }
    }
    if (latestReturnUtc == null) continue;

    final latestReturnLocal = toLocalDate(latestReturnUtc, localOffset);
    if (period.containsLocalDate(latestReturnLocal)) {
      final days = billableDays(
        rental.rentedAt,
        latestReturnUtc,
        localOffset: localOffset,
      );
      durationSum += days;
      completedInPeriodCount++;
    }
  }

  final averageDurationDays = completedInPeriodCount > 0
      ? durationSum / completedInPeriodCount
      : null;

  // 6-month duration trend ending in current month
  final durationMonthlyTrend = <MonthDurationMetric>[];
  for (var i = 5; i >= 0; i--) {
    var year = nowLocal.year;
    var month = nowLocal.month - i;
    while (month < 1) {
      month += 12;
      year -= 1;
    }

    var monthDurationSum = 0;
    var monthCompletedCount = 0;
    for (final rental in completedRentals) {
      final events = returnEventsByRentalId[rental.id] ?? const [];
      if (events.isEmpty) continue;
      DateTime? latestReturnUtc;
      for (final event in events) {
        if (latestReturnUtc == null ||
            event.returnedAt.isAfter(latestReturnUtc)) {
          latestReturnUtc = event.returnedAt;
        }
      }
      if (latestReturnUtc == null) continue;
      final local = toLocalDate(latestReturnUtc, localOffset);
      if (local.year == year && local.month == month) {
        monthDurationSum += billableDays(
          rental.rentedAt,
          latestReturnUtc,
          localOffset: localOffset,
        );
        monthCompletedCount++;
      }
    }

    durationMonthlyTrend.add(
      MonthDurationMetric(
        year: year,
        month: month,
        averageDays: monthCompletedCount > 0
            ? monthDurationSum / monthCompletedCount
            : null,
      ),
    );
  }

  // 3. Most rented materials
  final materialUnitDays = <String, int>{};
  for (final event in validReturnEvents) {
    final local = toLocalDate(event.returnedAt, localOffset);
    if (period.containsLocalDate(local)) {
      final line = validLines.cast<RentalLine?>().firstWhere(
        (l) => l?.id == event.rentalItemId,
        orElse: () => null,
      );
      if (line != null && line.materialId.isNotEmpty) {
        materialUnitDays[line.materialId] =
            (materialUnitDays[line.materialId] ?? 0) +
            (event.quantity * event.billableDays);
      }
    }
  }

  // Rentals created in period
  final rentalsCreatedInPeriod = validRentals.where((r) {
    final local = toLocalDate(r.rentedAt, localOffset);
    return period.containsLocalDate(local);
  }).toList();

  final materialTimesRented = <String, int>{};
  final materialTotalQuantity = <String, int>{};

  for (final rental in rentalsCreatedInPeriod) {
    final linesForRental = linesByRentalId[rental.id] ?? const [];
    final seenMaterialsInRental = <String>{};
    for (final line in linesForRental) {
      materialTotalQuantity[line.materialId] =
          (materialTotalQuantity[line.materialId] ?? 0) + line.quantity;
      if (seenMaterialsInRental.add(line.materialId)) {
        materialTimesRented[line.materialId] =
            (materialTimesRented[line.materialId] ?? 0) + 1;
      }
    }
  }

  final allInvolvedMaterialIds = <String>{
    ...materialUnitDays.keys,
    ...materialTimesRented.keys,
    ...materialTotalQuantity.keys,
  };

  final mostRentedMaterials = allInvolvedMaterialIds.map((matId) {
    final mat = materialMap[matId];
    final lineSnapshot = validLines.cast<RentalLine?>().firstWhere(
      (l) => l?.materialId == matId,
      orElse: () => null,
    );
    final name = mat?.name ?? lineSnapshot?.materialNameSnapshot ?? 'Unknown';
    final category = mat?.category ?? 'Panel';

    return MaterialRentalMetric(
      materialId: matId,
      materialName: name,
      category: category,
      unitDays: materialUnitDays[matId] ?? 0,
      timesRented: materialTimesRented[matId] ?? 0,
      totalQuantity: materialTotalQuantity[matId] ?? 0,
    );
  }).toList();

  // Default sort by unitDays descending, tie break by name ascending
  mostRentedMaterials.sort((a, b) {
    final cmp = b.unitDays.compareTo(a.unitDays);
    if (cmp != 0) return cmp;
    return a.materialName.compareTo(b.materialName);
  });

  // 4. Currently out (not period-filtered)
  final activeOrPartialRentals = validRentals
      .where(
        (r) =>
            r.status == RentalStatus.active ||
            r.status == RentalStatus.partiallyReturned,
      )
      .toList();

  final activeRentalsCount = activeOrPartialRentals.length;

  final materialUnitsOutMap = <String, int>{};
  for (final rental in activeOrPartialRentals) {
    final rentalLines = linesByRentalId[rental.id] ?? const [];
    for (final line in rentalLines) {
      final out = line.outstandingQuantity;
      if (out > 0) {
        materialUnitsOutMap[line.materialId] =
            (materialUnitsOutMap[line.materialId] ?? 0) + out;
      }
    }
  }

  final materialsCurrentlyOut = materialUnitsOutMap.entries.map((entry) {
    final mat = materialMap[entry.key];
    final lineSnapshot = validLines.cast<RentalLine?>().firstWhere(
      (l) => l?.materialId == entry.key,
      orElse: () => null,
    );
    return MaterialStockOutMetric(
      materialId: entry.key,
      materialName:
          mat?.name ?? lineSnapshot?.materialNameSnapshot ?? 'Unknown',
      category: mat?.category ?? 'Panel',
      unitsOut: entry.value,
      totalStock: mat?.totalStock,
    );
  }).toList();

  materialsCurrentlyOut.sort((a, b) {
    final cmp = b.unitsOut.compareTo(a.unitsOut);
    if (cmp != 0) return cmp;
    return a.materialName.compareTo(b.materialName);
  });

  // Long-running rentals
  final longRunningRentals = <LongRunningRentalMetric>[];
  for (final rental in activeOrPartialRentals) {
    final days = billableDays(
      rental.rentedAt,
      nowUtc,
      localOffset: localOffset,
    );
    if (days >= longRunningThresholdDays) {
      final cust = customerMap[rental.customerId];
      final rLines = linesByRentalId[rental.id] ?? const [];
      final summary = rLines
          .map((l) => '${l.outstandingQuantity}x ${l.materialNameSnapshot}')
          .join(', ');

      longRunningRentals.add(
        LongRunningRentalMetric(
          rentalId: rental.id,
          rentalNumber: rental.rentalNumber,
          customerId: rental.customerId,
          customerName: cust?.fullName ?? 'Unknown',
          rentedAtUtc: rental.rentedAt,
          daysSoFar: days,
          itemsSummary: summary,
        ),
      );
    }
  }

  longRunningRentals.sort((a, b) {
    final cmp = b.daysSoFar.compareTo(a.daysSoFar);
    if (cmp != 0) return cmp;
    return a.rentedAtUtc.compareTo(b.rentedAtUtc);
  });

  // 5. Customers in period: new vs returning + rankings
  final customerFirstRentalDate = <String, DateTime>{};
  for (final rental in validRentals) {
    final current = customerFirstRentalDate[rental.customerId];
    if (current == null || rental.rentedAt.isBefore(current)) {
      customerFirstRentalDate[rental.customerId] = rental.rentedAt;
    }
  }

  final customersWithRentalInPeriod = <String>{};
  final customerPeriodRentalsCount = <String, int>{};
  for (final rental in rentalsCreatedInPeriod) {
    customersWithRentalInPeriod.add(rental.customerId);
    customerPeriodRentalsCount[rental.customerId] =
        (customerPeriodRentalsCount[rental.customerId] ?? 0) + 1;
  }

  var newCustomersCount = 0;
  var returningCustomersCount = 0;
  for (final custId in customersWithRentalInPeriod) {
    final firstUtc = customerFirstRentalDate[custId];
    if (firstUtc != null) {
      final firstLocal = toLocalDate(firstUtc, localOffset);
      if (period.containsLocalDate(firstLocal)) {
        newCustomersCount++;
      } else if (firstLocal.isBefore(period.startDateLocal)) {
        returningCustomersCount++;
      }
    }
  }

  final customerPeriodRevenue = <String, int>{};
  for (final event in validReturnEvents) {
    final local = toLocalDate(event.returnedAt, localOffset);
    if (period.containsLocalDate(local)) {
      final rental = validRentals.cast<RentalRecord?>().firstWhere(
        (r) => r?.id == event.rentalId,
        orElse: () => null,
      );
      if (rental != null) {
        customerPeriodRevenue[rental.customerId] =
            (customerPeriodRevenue[rental.customerId] ?? 0) + event.amount;
      }
    }
  }

  final topCustomersByRevenue =
      customerPeriodRevenue.entries.map((entry) {
        final cust = customerMap[entry.key];
        return CustomerRankMetric(
          customerId: entry.key,
          customerName: cust?.fullName ?? 'Unknown',
          earnedRevenue: entry.value,
          rentalsCount: customerPeriodRentalsCount[entry.key] ?? 0,
        );
      }).toList()..sort((a, b) {
        final cmp = b.earnedRevenue.compareTo(a.earnedRevenue);
        if (cmp != 0) return cmp;
        return a.customerName.compareTo(b.customerName);
      });

  final topCustomersByRentals =
      customerPeriodRentalsCount.entries.map((entry) {
        final cust = customerMap[entry.key];
        return CustomerRankMetric(
          customerId: entry.key,
          customerName: cust?.fullName ?? 'Unknown',
          earnedRevenue: customerPeriodRevenue[entry.key] ?? 0,
          rentalsCount: entry.value,
        );
      }).toList()..sort((a, b) {
        final cmp = b.rentalsCount.compareTo(a.rentalsCount);
        if (cmp != 0) return cmp;
        return a.customerName.compareTo(b.customerName);
      });

  // 6. Outstanding estimate
  var outstandingEstimate = 0;
  for (final rental in activeOrPartialRentals) {
    final rentalLines = linesByRentalId[rental.id] ?? const [];
    outstandingEstimate += rentalEstimate(
      rentalLines.map(
        (line) => (
          quantity: line.quantity,
          quantityReturned: line.quantityReturned,
          pricePerDaySnapshot: line.pricePerDaySnapshot,
        ),
      ),
      rentedAtUtc: rental.rentedAt,
      asOfUtc: nowUtc,
      localOffset: localOffset,
    );
  }

  return DashboardMetrics(
    period: period,
    periodEarnedRevenue: periodEarnedRevenue,
    monthlyRevenueChart: monthlyRevenueChart,
    previousMonthRevenue: previousMonthRevenue,
    monthOverMonthChangePercent: monthOverMonthChangePercent,
    averageDurationDays: averageDurationDays,
    durationMonthlyTrend: durationMonthlyTrend,
    mostRentedMaterials: mostRentedMaterials,
    activeRentalsCount: activeRentalsCount,
    materialsCurrentlyOut: materialsCurrentlyOut,
    longRunningRentals: longRunningRentals,
    longRunningThresholdDays: longRunningThresholdDays,
    newCustomersCount: newCustomersCount,
    returningCustomersCount: returningCustomersCount,
    topCustomersByRevenue: topCustomersByRevenue.take(5).toList(),
    topCustomersByRentals: topCustomersByRentals.take(5).toList(),
    outstandingEstimate: outstandingEstimate,
  );
}

double? computeMonthOverMonthPercent({
  required int current,
  required int previous,
}) {
  if (previous == 0) {
    if (current == 0) return 0.0;
    return null; // Undefined / infinite change when previous is 0 and current > 0
  }
  return ((current - previous) / previous) * 100.0;
}
