import 'package:equatable/equatable.dart';
import 'package:fray/models/settings_enum.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class LanguageChanged extends SettingsEvent {
  final Language language;

  const LanguageChanged(this.language);

  @override
  List<Object> get props => [language];
}

class ThemeModeChanged extends SettingsEvent {
  final bool isDarkMode;

  const ThemeModeChanged(this.isDarkMode);

  @override
  List<Object> get props => [isDarkMode];
}

class CalendarViewChanged extends SettingsEvent {
  final CalendarView calendarView;

  const CalendarViewChanged(this.calendarView);

  @override
  List<Object> get props => [calendarView];
}
