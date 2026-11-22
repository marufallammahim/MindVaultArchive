import 'package:material_ui/material_ui.dart';
import 'package:mindvault_archive/app/theme.dart';

/// Consistent introductory panel for secondary MindVault feature screens.
///
/// The flat sunflower surface, cyan icon tile, dark outline and unblurred
/// offset shadow carry the supplied Neo-Brutalist visual language into every
/// route that uses this shared component.
class FeatureHero extends StatelessWidget {
  const FeatureHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppTheme.ink, width: 2.5),
        boxShadow: const [
          BoxShadow(color: AppTheme.ink, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 44 : 50,
            height: compact ? 44 : 50,
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppTheme.ink, width: 2),
            ),
            child: Icon(icon, color: AppTheme.ink, size: compact ? 22 : 25),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppTheme.ink.withValues(alpha: .82),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
