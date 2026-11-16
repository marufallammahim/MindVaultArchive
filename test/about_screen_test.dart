import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/widgets/feature_hero.dart';
import 'package:mindvault_archive/core/widgets/neo_brutalist_panel.dart';
import 'package:mindvault_archive/features/about/presentation/about_screen.dart';

void main() {
  testWidgets('About screen uses branded panels and explains local privacy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const AboutScreen()),
    );

    expect(find.byType(FeatureHero), findsOneWidget);
    expect(find.byType(NeoBrutalistPanel), findsNWidgets(3));
    expect(find.text('MindVault Archive'), findsOneWidget);
    expect(find.text('Maruf Allam Mahim'), findsOneWidget);
    expect(
      find.text(
        'Notes and attachments stay on this device. No remote sync is configured.',
      ),
      findsOneWidget,
    );

    final githubTile = tester.widget<ListTile>(
      find.ancestor(of: find.text('GitHub'), matching: find.byType(ListTile)),
    );
    expect(githubTile.onTap, isNotNull);
    expect(find.byTooltip('Copy GitHub profile link'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
