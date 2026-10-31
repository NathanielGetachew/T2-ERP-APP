import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/materials/presentation/material_editor_screen.dart';
import '../features/materials/presentation/materials_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
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
