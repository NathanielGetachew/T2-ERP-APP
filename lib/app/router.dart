import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/customers/presentation/customer_detail_screen.dart';
import '../features/customers/presentation/customer_editor_screen.dart';
import '../features/customers/presentation/customers_screen.dart';
import '../features/materials/presentation/material_editor_screen.dart';
import '../features/materials/presentation/materials_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

GoRouter createAppRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomersScreen(),
    ),
    GoRoute(
      path: '/customers/new',
      builder: (context, state) => const CustomerEditorScreen(),
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
  ],
);

final appRouter = createAppRouter();
