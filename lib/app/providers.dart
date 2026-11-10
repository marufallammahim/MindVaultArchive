import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  static const _storageKey = 'theme_mode';

  Future<void> _load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final stored = preferences.getString(_storageKey);
      if (!mounted || stored == null) return;
      state = ThemeMode.values.firstWhere(
        (mode) => mode.name == stored,
        orElse: () => ThemeMode.dark,
      );
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_storageKey, mode.name);
    } catch (_) {}
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class AmoledThemeNotifier extends StateNotifier<bool> {
  AmoledThemeNotifier() : super(true) {
    _load();
  }

  static const _storageKey = 'amoled_theme_enabled';

  Future<void> _load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      state = preferences.getBool(_storageKey) ?? true;
    } catch (_) {}
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_storageKey, enabled);
    } catch (_) {}
  }
}

final amoledThemeProvider = StateNotifierProvider<AmoledThemeNotifier, bool>(
  (ref) => AmoledThemeNotifier(),
);

class AccentColorNotifier extends StateNotifier<Color> {
  AccentColorNotifier() : super(const Color(0xFF7A1735)) {
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
