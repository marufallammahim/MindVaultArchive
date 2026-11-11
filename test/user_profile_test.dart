import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/app/providers.dart';

void main() {
  group('UserProfile', () {
    test('returns no avatar for empty or malformed stored image data', () {
      expect(const UserProfile(name: 'Test').avatar, isNull);
      expect(
        const UserProfile(name: 'Test', avatarBase64: '').avatar,
        isNull,
      );
      expect(
        const UserProfile(name: 'Test', avatarBase64: 'not-valid-base64')
            .avatar,
        isNull,
      );
    });

    test('decodes valid base64 avatar data', () {
      final profile = UserProfile(
        name: 'Test',
        avatarBase64: 'AQIDBA==',
      );

      expect(profile.avatar, isNotNull);
    });
  });
}
