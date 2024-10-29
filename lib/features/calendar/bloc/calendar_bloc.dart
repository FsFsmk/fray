import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/calendar/bloc/calendar_event.dart';
import 'package:fray/features/calendar/bloc/calendar_state.dart';
import 'package:fray/features/settings/bloc/settings_state.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/models/headache_log.dart';
import 'package:fray/models/settings_enum.dart';
import 'package:fray/repositories/headache_log_repository.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final HeadacheLogRepository headacheLogRepository;
  late final StreamSubscription<DateTime> updateSubscription;
  final SettingsState settingsState;

  CalendarBloc({
    required this.headacheLogRepository,
    required Stream<DateTime> updateStream,
    required this.settingsState,
  }) : super(CalendarState(
          selectedDay: null,
          hasHeadacheLogs: false,
          headacheIntensities: const {},
          logs: const [],
          currentDateRange: determineDateRangeFromSettings(settingsState),
        )) {
    updateSubscription = updateStream.listen((updatedDate) {
      if (state.currentDateRange.start.isBefore(updatedDate) &&
          state.currentDateRange.end.isAfter(updatedDate)) {
        add(LoadData(state.currentDateRange));
      }
    });

    on<SelectDay>((event, emit) async {
      final hasLogs =
          await headacheLogRepository.hasLogsForDay(event.selectedDay);
      emit(state.copyWith(
        selectedDay: event.selectedDay,
        hasHeadacheLogs: hasLogs,
      ));
    });

    on<LoadData>((event, emit) async {
      final Map<DateTime, List<HeadacheIntensity>> intensities = {};
      final List<HeadacheLog> logs = [];

      DateTime firstDay = event.dateRange.start;
      DateTime lastDay = event.dateRange.end;

      for (DateTime date = firstDay;
          !date.isAfter(lastDay);
          date = date.add(const Duration(days: 1))) {
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);

        final hasLogs =
            await headacheLogRepository.hasLogsForDay(normalizedDate);
        if (hasLogs) {
          final dayIntensities = await headacheLogRepository
              .getHeadacheIntensitiesForDay(normalizedDate);
          intensities[normalizedDate] = dayIntensities;

          final dayLogs =
              await headacheLogRepository.getHeadacheLogsForDay(normalizedDate);

          logs.addAll(dayLogs);
        }
      }

      emit(state.copyWith(
        headacheIntensities: intensities,
        logs: logs,
        currentDateRange: event.dateRange,
      ));
    });
  }

  static DateTimeRange determineDateRangeFromSettings(SettingsState settings) {
    DateTime baseDate = DateTime.now();
    switch (settings.calendarView) {
      case CalendarView.monthly:
        return DateTimeRange(
          start: DateTime(baseDate.year, baseDate.month, 1),
          end: DateTime(baseDate.year, baseDate.month + 1, 0),
        );
      case CalendarView.weekly:
        int weekday = baseDate.weekday;
        DateTime startWeek = baseDate.subtract(Duration(days: weekday - 1));
        DateTime endWeek = baseDate.add(Duration(days: 7 - weekday));
        return DateTimeRange(start: startWeek, end: endWeek);
      case CalendarView.daily:
        return DateTimeRange(start: baseDate, end: baseDate);
    }
  }

  @override
  Future<void> close() {
    updateSubscription.cancel();
    return super.close();
  }
}
