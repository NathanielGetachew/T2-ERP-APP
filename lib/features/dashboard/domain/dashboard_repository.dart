import '../../customers/domain/customer.dart';
import '../../materials/domain/rental_material.dart';
import '../../rentals/domain/rental.dart';

class DashboardDataSnapshot {
  const DashboardDataSnapshot({
    required this.rentals,
    required this.lines,
    required this.returnEvents,
    required this.customers,
    required this.materials,
  });

  final List<RentalRecord> rentals;
  final List<RentalLine> lines;
  final List<ReturnEventRecord> returnEvents;
  final List<Customer> customers;
  final List<RentalMaterial> materials;
}

abstract interface class DashboardRepository {
  Future<DashboardDataSnapshot> loadSnapshot();
  Stream<void> watchChanges();
}
