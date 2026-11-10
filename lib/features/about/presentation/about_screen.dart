import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('About')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Icon(Icons.archive_rounded,
                size: 80, color: Colors.deepPurple),
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
            const SizedBox(height: 32),
            const Divider(),
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
            const Divider(),
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
