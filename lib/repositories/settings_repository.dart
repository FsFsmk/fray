import 'package:shared_preferences/shared_preferences.dart';
import 'package:fray/models/settings_enum.dart';

class SettingsRepository {
  late final SharedPreferences _preferences;

  static SettingsRepository? _instance;

  static Future<SettingsRepository> getInstance() async {
    if (_instance == null) {
      _instance = SettingsRepository._();
      await _instance!._initializePreferences();
    }
    return _instance!;
  }

  SettingsRepository._();

  Future<void> _initializePreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> saveLanguage(Language language) async {
    await _preferences.setString('language', language.name);
  }

  Future<Language> getLanguage() async {
    final String? languageName = _preferences.getString('language');
    if (languageName != null) {
      return Language.values.firstWhere((e) => e.name == languageName);
    } else {
      return Language.en;
    }
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    await _preferences.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> getThemeMode() async {
    final bool? isDarkMode = _preferences.getBool('isDarkMode');
    return isDarkMode ?? false;
  }

  Future<void> saveCalendarView(CalendarView calendarView) async {
    await _preferences.setString('calendarView', calendarView.name);
  }

  Future<CalendarView> getCalendarView() async {
    final String? calendarViewName = _preferences.getString('calendarView');
    if (calendarViewName != null) {
      return CalendarView.values.firstWhere((e) => e.name == calendarViewName);
    } else {
      return CalendarView.monthly;
    }
  }
}
