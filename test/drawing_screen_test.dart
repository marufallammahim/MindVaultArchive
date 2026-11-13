import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/drawing/presentation/drawing_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('drawing refuses missing notes without creating a ghost note', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DrawingScreen(noteId: 'missing-note'),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Save drawing'));
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(await database.select(database.notes).get(), isEmpty);
    expect(find.textContaining('active note'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
