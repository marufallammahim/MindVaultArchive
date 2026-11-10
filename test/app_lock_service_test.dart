import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/features/security/data/app_lock_service.dart';

class _MemorySecureStore implements SecureValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
  test('temporarily locks after five incorrect PIN attempts', () async {
    final service = AppLockService(store: _MemorySecureStore());
    await service.setPin('593817');

    for (var attempt = 0; attempt < 5; attempt++) {
      expect(await service.verifyPin('000000'), isFalse);
    }

    expect(await service.lockoutRemaining(), isNotNull);
    expect(await service.verifyPin('593817'), isFalse);
  });

}

void main() {
  test('stores a salted PIN hash and verifies correct PIN', () async {
    final store = _MemorySecureStore();
    final service = AppLockService(store: store);

    await service.setPin('482915');

    expect(await service.isEnabled(), isTrue);
    expect(await service.verifyPin('482915'), isTrue);
    expect(await service.verifyPin('482914'), isFalse);
    expect(store.values.values, isNot(contains('482915')));
  });

  test('rejects invalid PIN and requires the current PIN to disable', () async {
    final store = _MemorySecureStore();
    final service = AppLockService(store: store);

    await expectLater(service.setPin('1234'), throwsArgumentError);
    await service.setPin('731904');
    await expectLater(
      service.disablePin('000000'),
      throwsA(isA<StateError>()),
    );
    expect(await service.isEnabled(), isTrue);

    await service.disablePin('731904');
    expect(await service.isEnabled(), isFalse);
    expect(await service.verifyPin('731904'), isFalse);
  });
}
