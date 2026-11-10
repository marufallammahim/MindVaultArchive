import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Appearance'),
            subtitle: Text('Choose how MindVault Archive looks'),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System default'),
            value: ThemeMode.system,
            groupValue: mode,
            onChanged: (value) => ref.read(themeModeProvider.notifier).state = value!,
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: mode,
            onChanged: (value) => ref.read(themeModeProvider.notifier).state = value!,
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: mode,
            onChanged: (value) => ref.read(themeModeProvider.notifier).state = value!,
          ),
          const Divider(),
          const ListTile(
            title: Text('Storage'),
            subtitle: Text('Notes are stored locally on this device'),
            leading: Icon(Icons.storage_outlined),
          ),
        ],
      ),
    );
  }
}
