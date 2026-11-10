import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/customers/presentation/customer_detail_screen.dart';
import '../features/customers/presentation/customer_editor_screen.dart';
import '../features/customers/presentation/customers_screen.dart';
import '../features/customers/domain/customer.dart';
import '../features/materials/presentation/material_editor_screen.dart';
import '../features/materials/presentation/materials_screen.dart';
import '../features/rentals/presentation/rental_detail_screen.dart';
import '../features/rentals/presentation/rental_editor_screen.dart';
import '../features/rentals/presentation/rentals_screen.dart';
import '../features/rentals/presentation/return_screen.dart';
import '../features/rentals/presentation/return_summary_screen.dart';
import '../features/rentals/domain/rental.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/backup_screen.dart';

GoRouter createAppRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/backup',
      builder: (context, state) => const BackupScreen(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomersScreen(),
    ),
    GoRoute(
      path: '/customers/new',
      builder: (context, state) => CustomerEditorScreen(
        onSaved: state.extra is ValueChanged<Customer>
            ? state.extra as ValueChanged<Customer>
            : null,
      ),
    ),
    GoRoute(
      path: '/customers/:id',
      builder: (context, state) =>
          CustomerDetailScreen(customerId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/customers/:id/edit',
      builder: (context, state) =>
          CustomerEditorScreen(customerId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/customers/:id/photo',
      builder: (context, state) =>
          CustomerPhotoViewerScreen(customerId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/materials',
      builder: (context, state) => const MaterialsScreen(),
    ),
    GoRoute(
      path: '/materials/new',
      builder: (context, state) => const MaterialEditorScreen(),
    ),
    GoRoute(
      path: '/materials/edit',
      builder: (context, state) =>
          MaterialEditorScreen(materialId: state.uri.queryParameters['id']),
    ),
    GoRoute(
      path: '/rentals',
      builder: (context, state) => const RentalsScreen(),
    ),
    GoRoute(
      path: '/rentals/new',
      builder: (context, state) => RentalEditorScreen(
        recreateFrom: state.extra is RentalDetails
            ? state.extra as RentalDetails
            : null,
      ),
    ),
    GoRoute(
      path: '/rentals/:id',
      builder: (context, state) =>
          RentalDetailScreen(rentalId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/rentals/:id/return',
      builder: (context, state) =>
          ReturnScreen(rentalId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/rentals/:id/return-summary',
      builder: (context, state) =>
          ReturnSummaryScreen(receipt: state.extra! as ReturnReceipt),
    ),
  ],
);

final appRouter = createAppRouter();
