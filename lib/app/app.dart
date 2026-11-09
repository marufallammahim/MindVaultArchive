import 'package:flutter/material.dart';
import 'package:mindvault_archive/app/router.dart';
import 'package:mindvault_archive/app/theme.dart';

class MindVaultArchiveApp extends StatelessWidget {
  const MindVaultArchiveApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'MindVault Archive',
        themeMode: ThemeMode.system,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      );
}