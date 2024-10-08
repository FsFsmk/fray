import 'package:equatable/equatable.dart';
import 'package:fray/models/settings_enum.dart';

class SettingsState extends Equatable {
  final Language language;
  final bool isDarkMode;
  final CalendarView calendarView;

  const SettingsState({
    this.language = Language.en,
    this.isDarkMode = false,
    this.calendarView = CalendarView.monthly,
  });

  SettingsState copyWith({
    Language? language,
    bool? isDarkMode,
    CalendarView? calendarView,
  }) {
    return SettingsState(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      calendarView: calendarView ?? this.calendarView,
    );
  }

  @override
  List<Object> get props => [language, isDarkMode, calendarView];
}
