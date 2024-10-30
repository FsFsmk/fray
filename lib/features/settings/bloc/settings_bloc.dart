import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/repositories/settings_repository.dart';
import 'package:fray/features/settings/bloc/settings_event.dart';
import 'package:fray/features/settings/bloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository})
      : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<LanguageChanged>(_onLanguageChanged);
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<CalendarViewChanged>(_onCalendarViewChanged);

    add(LoadSettings());
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final language = await settingsRepository.getLanguage();
    final isDarkMode = await settingsRepository.getThemeMode();
    final calendarView = await settingsRepository.getCalendarView();

    emit(SettingsState(
      language: language,
      isDarkMode: isDarkMode,
      calendarView: calendarView,
    ));
  }

  Future<void> _onLanguageChanged(
    LanguageChanged event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(language: event.language));
    await settingsRepository.saveLanguage(event.language);
  }

  Future<void> _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isDarkMode: event.isDarkMode));
    await settingsRepository.saveThemeMode(event.isDarkMode);
  }

  Future<void> _onCalendarViewChanged(
    CalendarViewChanged event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(calendarView: event.calendarView));
    await settingsRepository.saveCalendarView(event.calendarView);
  }
}
