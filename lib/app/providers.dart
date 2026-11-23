import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindvault_archive/app/theme.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

class ThemePresetNotifier extends StateNotifier<AppThemePreset> {
  ThemePresetNotifier() : super(AppThemePreset.amoled) {
    initialized = _load();
  }

  static const _storageKey = 'theme_preset';
  static const _legacyModeKey = 'theme_mode';
  static const _legacyAmoledKey = 'amoled_theme_enabled';
  late final Future<void> initialized;

  Future<void> _load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      final stored = preferences.getString(_storageKey);
      final restored = AppThemePreset.values.where(
        (preset) => preset.name == stored,
      );
      if (restored.isNotEmpty) {
        state = restored.first;
        await preferences.remove(_legacyModeKey);
        await preferences.remove(_legacyAmoledKey);
        return;
      }
      final oldMode = preferences.getString(_legacyModeKey);
      final oldAmoled = preferences.getBool(_legacyAmoledKey);
      if (oldMode == null && oldAmoled == null) {
        state = AppThemePreset.amoled;
      } else if (oldMode == 'light') {
        state = AppThemePreset.light;
      } else if (oldMode == 'dark' && oldAmoled == false) {
        state = AppThemePreset.dark;
      } else if (oldMode == 'dark' && oldAmoled != false) {
        state = AppThemePreset.amoled;
      } else {
        state = AppThemePreset.dark;
      }
      await preferences.setString(_storageKey, state.name);
      await preferences.remove(_legacyModeKey);
      await preferences.remove(_legacyAmoledKey);
    } catch (_) {}
  }

  Future<void> setPreset(AppThemePreset preset) async {
    await initialized;
    if (!mounted) return;
    state = preset;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_storageKey, preset.name);
      await preferences.remove(_legacyModeKey);
      await preferences.remove(_legacyAmoledKey);
    } catch (_) {}
  }
}

final themePresetProvider =
    StateNotifierProvider<ThemePresetNotifier, AppThemePreset>(
      (ref) => ThemePresetNotifier(),
    );

class AccentColorNotifier extends StateNotifier<Color> {
  AccentColorNotifier() : super(const Color(0xFFF7CB46)) {
    _load();
  }

  static const _storageKey = 'primary_accent_color';

  Future<void> _load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final value = preferences.getInt(_storageKey);
      if (mounted && value != null) state = Color(value);
    } catch (_) {}
  }

  Future<void> setColor(Color color) async {
    state = color;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt(_storageKey, color.toARGB32());
    } catch (_) {}
  }
}

final accentColorProvider = StateNotifierProvider<AccentColorNotifier, Color>(
  (ref) => AccentColorNotifier(),
);

class UserProfile {
  const UserProfile({required this.name, this.avatarBase64});

  final String name;
  final String? avatarBase64;

  ImageProvider<Object>? get avatar {
    final value = avatarBase64;
    if (value == null || value.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(value));
    } catch (_) {
      return null;
    }
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile(name: 'Your name')) {
    _load();
  }

  static const _nameKey = 'profile_display_name';
  static const _avatarKey = 'profile_avatar_base64';

  Future<void> _load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      state = UserProfile(
        name: preferences.getString(_nameKey) ?? 'Your name',
        avatarBase64: preferences.getString(_avatarKey),
      );
    } catch (_) {}
  }

  Future<void> save({required String name, String? avatarBase64}) async {
    final cleanName = name.trim().isEmpty ? 'Your name' : name.trim();
    state = UserProfile(name: cleanName, avatarBase64: avatarBase64);
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_nameKey, cleanName);
      if (avatarBase64 == null || avatarBase64.isEmpty) {
        await preferences.remove(_avatarKey);
      } else {
        await preferences.setString(_avatarKey, avatarBase64);
      }
    } catch (_) {}
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
      (ref) => UserProfileNotifier(),
    );
