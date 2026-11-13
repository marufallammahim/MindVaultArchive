import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/features/security/data/app_lock_service.dart';
import 'package:mindvault_archive/features/security/presentation/app_lock_gate.dart';

class _MemorySecureStore implements SecureValueStore {
  final values = <String, String>{};
  bool failReads = false;

  @override
  Future<String?> read(String key) async {
    if (failReads) throw StateError('Secure storage unavailable');
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  int maxFrames = 20,
}) async {
  for (var frame = 0; frame < maxFrames; frame++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 50));
  }
  fail('Widget did not become visible within $maxFrames frames: $finder');
}

void main() {
  testWidgets('app lock gate displays the app after a valid PIN', (
    tester,
  ) async {
    final store = _MemorySecureStore();
    final service = AppLockService(store: store);
    await service.setPin('482915');

    await tester.pumpWidget(
      MaterialApp(
        home: AppLockGate(
          service: service,
          child: const Scaffold(body: Text('Vault home')),
        ),
      ),
    );
    await _pumpUntilVisible(tester, find.text('MindVault is locked'));

    expect(find.text('MindVault is locked'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '482915');
    await tester.tap(find.text('Unlock'));
    await _pumpUntilVisible(tester, find.text('Vault home'));

    expect(find.text('Vault home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('app lock gate fails closed when secure storage is unavailable', (
    tester,
  ) async {
    final store = _MemorySecureStore()..failReads = true;
    final service = AppLockService(store: store);

    await tester.pumpWidget(
      MaterialApp(
        home: AppLockGate(
          service: service,
          child: const Scaffold(body: Text('Vault home')),
        ),
      ),
    );
    await _pumpUntilVisible(
      tester,
      find.textContaining('Could not verify secure app-lock settings'),
    );

    expect(
      find.textContaining('Could not verify secure app-lock settings'),
      findsOneWidget,
    );
    expect(find.text('Vault home'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('incorrect PIN shows an error without crashing', (tester) async {
    final store = _MemorySecureStore();
    final service = AppLockService(store: store);
    await service.setPin('482915');

    await tester.pumpWidget(
      MaterialApp(
        home: AppLockGate(
          service: service,
          child: const Scaffold(body: Text('Vault home')),
        ),
      ),
    );
    await _pumpUntilVisible(tester, find.text('MindVault is locked'));

    await tester.enterText(find.byType(TextField), '000000');
    await tester.tap(find.text('Unlock'));
    await _pumpUntilVisible(tester, find.text('Incorrect PIN. Try again.'));

    expect(find.text('Incorrect PIN. Try again.'), findsOneWidget);
    expect(find.text('Vault home'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
