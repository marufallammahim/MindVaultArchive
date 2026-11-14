import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/widgets/feature_hero.dart';

void main() {
  testWidgets('FeatureHero uses a flat palette block and hard offset shadow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: FeatureHero(
              icon: Icons.search_rounded,
              title: 'Search',
              subtitle: 'Find notes in your local archive.',
            ),
          ),
        ),
      ),
    );

    final hero = tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).color == AppTheme.primary,
      ),
    );
    final decoration = hero.decoration! as BoxDecoration;
    expect(decoration.gradient, isNull);
    expect(decoration.border, isA<Border>());
    expect((decoration.border! as Border).top.width, 2.5);
    expect(decoration.boxShadow, hasLength(1));
    expect(decoration.boxShadow!.single.blurRadius, 0);
    expect(decoration.boxShadow!.single.offset, const Offset(4, 4));
    expect(find.text('Search'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
