import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/features/splash/presentation/splash_screen.dart';
import 'package:mindvault_archive/features/home/presentation/home_screen.dart';
import 'package:mindvault_archive/features/editor/presentation/editor_screen.dart';
import 'package:mindvault_archive/features/drawing/presentation/drawing_screen.dart';
import 'package:mindvault_archive/features/settings/presentation/settings_screen.dart';
import 'package:mindvault_archive/features/about/presentation/about_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/editor/:id',
      builder: (context, state) =>
          EditorScreen(noteId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/drawing/:id',
      builder: (context, state) =>
          DrawingScreen(noteId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);