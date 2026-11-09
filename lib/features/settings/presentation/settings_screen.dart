import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkTheme = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          children: [
            SwitchListTile(
              title: const Text('Dark Theme preview'),
              subtitle: const Text('Theme preference is currently session-only'),
              value: _darkTheme,
              onChanged: (value) => setState(() => _darkTheme = value),
            ),
            const ListTile(
              title: Text('Typography'),
              subtitle: Text('Font and reading-density preferences are not yet available'),
            ),
            const ListTile(
              title: Text('Storage'),
              subtitle: Text('Notes are stored locally on this device'),
              leading: Icon(Icons.storage_outlined),
            ),
          ],
        ),
      );
}