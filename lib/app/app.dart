import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/app/router.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/main.dart';

class MindVaultArchiveApp extends ConsumerWidget {
  const MindVaultArchiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'MindVault Archive',
        themeMode: ref.watch(themeModeProvider),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      );
}
