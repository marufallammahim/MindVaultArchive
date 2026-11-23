import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/router.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/features/security/data/app_lock_service.dart';
import 'package:mindvault_archive/features/security/presentation/app_lock_gate.dart';

class MindVaultArchiveApp extends ConsumerWidget {
  const MindVaultArchiveApp({super.key, this.appLockService});

  final AppLockService? appLockService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(themePresetProvider);
    final accent = ref.watch(accentColorProvider);
    final selectedTheme = AppTheme.themeFor(preset, accent);
    return MaterialApp.router(
      title: 'MindVault Archive',
      theme: selectedTheme,
      darkTheme: selectedTheme,
      themeMode: preset.brightness == Brightness.light
          ? ThemeMode.light
          : ThemeMode.dark,
      routerConfig: appRouter,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en', 'US')],
      builder: (context, child) {
        final gatedChild = AppLockGate(
          service: appLockService,
          child: child ?? const SizedBox.shrink(),
        );
        return preset.isMonochrome
            ? ColorFiltered(
                colorFilter: AppTheme.monochromeColorFilter,
                child: gatedChild,
              )
            : gatedChild;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
