import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/router.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/features/security/data/app_lock_service.dart';
import 'package:mindvault_archive/features/security/presentation/app_lock_gate.dart';

class MindVaultArchiveApp extends ConsumerWidget {
  const MindVaultArchiveApp({super.key, AppLockService? appLockService})
      : _appLockService = appLockService;

  final AppLockService? _appLockService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final amoled = ref.watch(amoledThemeProvider);
    final accent = ref.watch(accentColorProvider);
    return MaterialApp.router(
      title: 'MindVault Archive',
      themeMode: mode,
      theme: AppTheme.lightThemeFor(accent),
      darkTheme: amoled
          ? AppTheme.amoledThemeFor(accent)
          : AppTheme.darkThemeFor(accent),
      routerConfig: appRouter,
      builder: (context, child) => AppLockGate(
        service: _appLockService,
        child: child ?? const SizedBox.shrink(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
