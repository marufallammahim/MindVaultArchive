import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('MindVault Flutter error: ${details.exceptionAsString()}');
    if (details.stack != null) debugPrintStack(stackTrace: details.stack);
  };
  ErrorWidget.builder = (details) {
    debugPrint('MindVault widget build error: ${details.exception}');
    if (details.stack != null) debugPrintStack(stackTrace: details.stack);
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return Material(
          color: theme.scaffoldBackgroundColor,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: scheme.error,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This screen could not be displayed.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your saved notes remain safe. Return home and try again.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => GoRouter.of(context).go('/home'),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Return to Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('MindVault uncaught platform error: $error');
    debugPrintStack(stackTrace: stack);
    return true;
  };
  runZonedGuarded(
    () => runApp(const ProviderScope(child: MindVaultArchiveApp())),
    (error, stack) {
      debugPrint('MindVault uncaught async error: $error');
      debugPrintStack(stackTrace: stack);
    },
  );
}
