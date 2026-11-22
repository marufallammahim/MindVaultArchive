import 'package:material_ui/material_ui.dart';
import 'package:mindvault_archive/app/branding_assets.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/widgets/feature_hero.dart';
import 'package:mindvault_archive/core/widgets/neo_brutalist_panel.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _copyGithubProfile(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: 'https://github.com/marufallammahim'),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GitHub profile link copied.')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('About')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
      children: [
        const FeatureHero(
          icon: Icons.auto_awesome_rounded,
          title: 'Your thoughts. Your archive.',
          subtitle:
              'A private, local-first home for ideas, knowledge and memories.',
        ),
        const SizedBox(height: 20),
        NeoBrutalistPanel(
          color: AppTheme.primary,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  color: AppTheme.lightSurface,
                  border: Border.all(color: AppTheme.ink, width: 2.5),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.ink,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.memory(
                    BrandingAssets.appLogo,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'MindVault Archive',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A private space for your thoughts, ideas, and memories.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.ink, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        NeoBrutalistPanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.tertiary,
                    border: Border.all(color: AppTheme.ink, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.person_outline, color: AppTheme.ink),
                ),
                title: const Text('Developer'),
                subtitle: const Text('Maruf Allam Mahim'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    border: Border.all(color: AppTheme.ink, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.code_rounded, color: AppTheme.ink),
                ),
                title: const Text('GitHub'),
                subtitle: const Text('github.com/marufallammahim'),
                trailing: const Tooltip(
                  message: 'Copy GitHub profile link',
                  child: Icon(Icons.copy_rounded),
                ),
                onTap: () => _copyGithubProfile(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        NeoBrutalistPanel(
          color: AppTheme.secondary,
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  border: Border.all(color: AppTheme.ink, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.privacy_tip_outlined,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy first',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Notes and attachments stay on this device. No remote sync is configured.',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.ink, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
