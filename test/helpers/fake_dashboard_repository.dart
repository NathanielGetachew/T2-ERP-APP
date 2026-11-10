import 'dart:async';

import 'package:t2_rental/features/customers/domain/customer.dart';
import 'package:t2_rental/features/dashboard/domain/dashboard_repository.dart';
import 'package:t2_rental/features/materials/domain/rental_material.dart';
import 'package:t2_rental/features/rentals/domain/rental.dart';

class FakeDashboardRepository implements DashboardRepository {
  FakeDashboardRepository({
    this.rentals = const [],
    this.lines = const [],
    this.returnEvents = const [],
    this.customers = const [],
    this.materials = const [],
  });

  List<RentalRecord> rentals;
  List<RentalLine> lines;
  List<ReturnEventRecord> returnEvents;
  List<Customer> customers;
  List<RentalMaterial> materials;

  final _controller = StreamController<void>.broadcast();

  void notify() => _controller.add(null);

  @override
  Future<DashboardDataSnapshot> loadSnapshot() async {
    return DashboardDataSnapshot(
      rentals: rentals,
      lines: lines,
      returnEvents: returnEvents,
      customers: customers,
      materials: materials,
    );
  }

  @override
  Stream<void> watchChanges() => _controller.stream;
}
