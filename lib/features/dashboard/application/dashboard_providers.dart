import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/utils/clock_provider.dart';
import '../data/drift_dashboard_repository.dart';
import '../domain/dashboard_metrics.dart';
import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';
import 'long_running_threshold_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DriftDashboardRepository(ref.watch(databaseProvider));
});

final dashboardPeriodProvider = StateProvider<DashboardPeriod>((ref) {
  final now = ref.watch(clockProvider).now();
  final localOffset = DateTime.now().timeZoneOffset;
  final nowLocal = now.toUtc().add(localOffset);
  return DashboardPeriod.thisMonth(nowLocal);
});

final dashboardMetricsProvider = StreamProvider.autoDispose<DashboardMetrics>((
  ref,
) async* {
  final repository = ref.watch(dashboardRepositoryProvider);
  final period = ref.watch(dashboardPeriodProvider);
  final threshold = ref.watch(longRunningThresholdProvider);
  final clock = ref.watch(clockProvider);
  final localOffset = DateTime.now().timeZoneOffset;

  Future<DashboardMetrics> load() async {
    final snapshot = await repository.loadSnapshot();
    return computeDashboardMetrics(
      rentals: snapshot.rentals,
      lines: snapshot.lines,
      returnEvents: snapshot.returnEvents,
      customers: snapshot.customers,
      materials: snapshot.materials,
      period: period,
      nowUtc: clock.now().toUtc(),
      localOffset: localOffset,
      longRunningThresholdDays: threshold,
    );
  }

  yield await load();

  await for (final _ in repository.watchChanges()) {
    yield await load();
  }
});
