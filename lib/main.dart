import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return const Material(
      color: Color(0xFF101014),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFFF8A80),
                size: 42,
              ),
              SizedBox(height: 12),
              Text(
                'This screen could not be displayed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'Go back and try again. Your saved notes remain safe.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
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
