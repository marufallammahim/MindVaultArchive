import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/app/theme.dart';

void main() {
  group('AppTheme', () {
    test('provides Material 3 light and dark themes', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
      expect(AppTheme.lightTheme.colorScheme.brightness, Brightness.light);
      expect(AppTheme.darkTheme.colorScheme.brightness, Brightness.dark);
    });
  });
}
