import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fray/models/enum_to_string.dart';
import 'package:fray/models/settings_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  late final SharedPreferences _preferences;

  static SettingsRepository? _instance;
  static Future<SettingsRepository> getInstance(BuildContext? context) async {
    if (_instance == null) {
      _instance = SettingsRepository._();
      await _instance!._initializePrefences(context);
    }
    return _instance!;
  }

  SettingsRepository._();

  Future<void> _initializePrefences(BuildContext? context) async {
    _initializeLanguage();
    if (context != null) {
      _initializeTheme(context);
    }
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> _initializeLanguage() async {
    if (_preferences.getString('locale') == null) {
      // ignore: deprecated_member_use
      String deviceLanguage = ui.window.locale.languageCode;
      Language defaultLanguage =
          (deviceLanguage == 'ar' || deviceLanguage == 'en')
              ? stringToLanguage(deviceLanguage)
              : Language.en;
      await _preferences.setString('locale', enumToString(defaultLanguage));
    }
  }

  Future<void> _initializeTheme(BuildContext context) async {
    if (_preferences.getBool('themeIsDarkMode') == null) {
      var brightness = MediaQuery.of(context).platformBrightness;
      bool isDarkMode = brightness == ui.Brightness.dark;
      await _preferences.setBool('themeIsDarkMode', isDarkMode);
    }
  }

  Language getLanguage() {
    String languageStr = _preferences.getString('language') ?? 'english';
    return stringToLanguage(languageStr);
  }

  Future<bool> setLanguage(Language language) async {
    return await _preferences.setString('language', enumToString(language));
  }

  bool getThemeIsDarkMode() {
    return _preferences.getBool('themeIsDarkMode') ?? true;
  }

  Future<bool> setThemeIsDarkMode(bool darkTheme) async {
    return await _preferences.setBool('themeIsDarkMode', darkTheme);
  }
}
