import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

enum JogjaThemeMode { light, dark, system }

final themeControllerProvider =
    StateNotifierProvider<ThemeController, JogjaThemeMode>(
  (ref) => ThemeController()..load(),
);

class ThemeController extends StateNotifier<JogjaThemeMode> {
  ThemeController() : super(JogjaThemeMode.dark);

  static const _key = 'jogjasplorasi_theme_mode';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    state = switch (value) {
      'light' => JogjaThemeMode.light,
      'system' => JogjaThemeMode.system,
      _ => JogjaThemeMode.dark,
    };
  }

  Future<void> setMode(JogjaThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  Future<void> toggleLightDark() async {
    await setMode(state == JogjaThemeMode.light
        ? JogjaThemeMode.dark
        : JogjaThemeMode.light);
  }
}

CupertinoThemeData themeForMode(JogjaThemeMode mode, Brightness platform) {
  final brightness = switch (mode) {
    JogjaThemeMode.light => Brightness.light,
    JogjaThemeMode.dark => Brightness.dark,
    JogjaThemeMode.system => platform,
  };
  return AppTheme.theme(brightness: brightness);
}
