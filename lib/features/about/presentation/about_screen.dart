import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('About')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
          children: [
            Icon(Icons.archive_rounded,
                size: 68, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'MindVault Archive',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'A private space for your thoughts, ideas, and memories.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Divider(height: 24),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text('Developer'),
              subtitle: Text('Maruf Allam Mahim'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('GitHub'),
              subtitle: const Text('github.com/marufallammahim'),
              onTap: () => Clipboard.setData(
                const ClipboardData(text: 'https://github.com/marufallammahim'),
              ),
            ),
            const Divider(height: 24),
            const ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text('Privacy'),
              subtitle: Text(
                'Notes are stored locally. No remote sync is configured.',
              ),
            ),
          ],
        ),
      );
}
