import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureValueStore implements SecureValueStore {
  const FlutterSecureValueStore([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Optional six-digit app screen lock.
///
/// This protects the app UI only. It does not encrypt the SQLite database or
/// attachment files, and must never be described as vault encryption.
class AppLockService {
  AppLockService({SecureValueStore? store})
      : _store = store ?? const FlutterSecureValueStore();

  static const _enabledKey = 'mindvault.app_lock.enabled';
  static const _saltKey = 'mindvault.app_lock.salt';
  static const _hashKey = 'mindvault.app_lock.pin_hash';

  final SecureValueStore _store;

  Future<bool> isEnabled() async =>
      await _store.read(_enabledKey) == 'true';

  Future<void> setPin(String pin) async {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      throw ArgumentError.value(pin, 'pin', 'PIN must contain six digits.');
    }
    final saltBytes = List<int>.generate(
      16,
      (_) => Random.secure().nextInt(256),
    );
    final salt = base64UrlEncode(saltBytes);
    final hash = sha256.convert(utf8.encode('$salt:$pin')).toString();

    await _store.write(_saltKey, salt);
    await _store.write(_hashKey, hash);
    await _store.write(_enabledKey, 'true');
  }

  Future<bool> verifyPin(String pin) async {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) return false;
    final salt = await _store.read(_saltKey);
    final expectedHash = await _store.read(_hashKey);
    if (salt == null || expectedHash == null) return false;

    final actual = sha256.convert(utf8.encode('$salt:$pin')).bytes;
    final expected = _decodeHex(expectedHash);
    if (expected == null || expected.length != actual.length) return false;

    var difference = 0;
    for (var index = 0; index < actual.length; index++) {
      difference |= actual[index] ^ expected[index];
    }
    return difference == 0;
  }

  Future<void> disablePin(String currentPin) async {
    if (!await verifyPin(currentPin)) {
      throw StateError('The current PIN is incorrect.');
    }
    await _store.delete(_enabledKey);
    await _store.delete(_saltKey);
    await _store.delete(_hashKey);
  }

  List<int>? _decodeHex(String value) {
    if (value.length != 64) return null;
    try {
      return List<int>.generate(
        32,
        (index) => int.parse(
          value.substring(index * 2, index * 2 + 2),
          radix: 16,
        ),
      );
    } on FormatException {
      return null;
    }
  }
}
