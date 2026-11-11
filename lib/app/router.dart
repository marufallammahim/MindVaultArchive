import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/features/splash/presentation/splash_screen.dart';
import 'package:mindvault_archive/features/home/presentation/home_screen.dart';
import 'package:mindvault_archive/features/editor/presentation/editor_screen.dart';
import 'package:mindvault_archive/features/drawing/presentation/drawing_screen.dart';
import 'package:mindvault_archive/features/settings/presentation/settings_screen.dart';
import 'package:mindvault_archive/features/about/presentation/about_screen.dart';
import 'package:mindvault_archive/features/archive/presentation/archive_tools_screen.dart';
import 'package:mindvault_archive/features/tasks/presentation/tasks_screen.dart';
import 'package:mindvault_archive/features/templates/presentation/templates_screen.dart';
import 'package:mindvault_archive/features/capture/presentation/quick_capture_screen.dart';
import 'package:mindvault_archive/features/tags/presentation/tags_screen.dart';
import 'package:mindvault_archive/features/history/presentation/revision_history_screen.dart';
import 'package:mindvault_archive/features/search/presentation/archive_search_screen.dart';
import 'package:mindvault_archive/features/security/presentation/app_lock_settings_screen.dart';
import 'package:mindvault_archive/features/insights/presentation/archive_insights_screen.dart';
import 'package:mindvault_archive/features/timeline/presentation/archive_timeline_screen.dart';
import 'package:mindvault_archive/features/developer/presentation/developer_notebook_screen.dart';
import 'package:mindvault_archive/features/trash/presentation/trash_screen.dart';
import 'package:mindvault_archive/features/trash/presentation/delete_confirmation_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/trash', builder: (context, state) => const TrashScreen()),
    GoRoute(
      path: '/delete/:id',
      builder: (context, state) =>
          DeleteConfirmationScreen(noteId: state.pathParameters['id']!),
    ),
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
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    GoRoute(
      path: '/tasks',
      builder: (context, state) =>
          TasksScreen(noteId: state.uri.queryParameters['noteId']),
    ),
    GoRoute(
      path: '/templates',
      builder: (context, state) => const TemplatesScreen(),
    ),
    GoRoute(
      path: '/capture',
      builder: (context, state) => const QuickCaptureScreen(),
    ),
    GoRoute(path: '/tags', builder: (context, state) => const TagsScreen()),
    GoRoute(
      path: '/history/:id',
      builder: (context, state) =>
          RevisionHistoryScreen(noteId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const ArchiveSearchScreen(),
    ),
    GoRoute(
      path: '/app-lock',
      builder: (context, state) => const AppLockSettingsScreen(),
    ),
    GoRoute(
      path: '/archive-tools',
      builder: (context, state) => const ArchiveToolsScreen(),
    ),
    GoRoute(
        path: '/insights',
        builder: (context, state) => const ArchiveInsightsScreen()),
    GoRoute(
        path: '/timeline',
        builder: (context, state) => const ArchiveTimelineScreen()),
    GoRoute(
        path: '/developer-notebook',
        builder: (context, state) => const DeveloperNotebookScreen()),
  ],
);
