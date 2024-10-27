import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/calendar/bloc/calendar_event.dart';
import 'package:fray/features/calendar/bloc/calendar_state.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/repositories/headache_log_repository.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final HeadacheLogRepository headacheLogRepository;

  CalendarBloc({required this.headacheLogRepository})
      : super(const CalendarState(
          selectedDay: null,
          hasHeadacheLogs: false,
          headacheIntensities: {},
        )) {
    on<SelectDay>((event, emit) async {
      final hasLogs =
          await headacheLogRepository.hasLogsForDay(event.selectedDay);
      emit(state.copyWith(
        selectedDay: event.selectedDay,
        hasHeadacheLogs: hasLogs,
      ));
    });
    on<LoadMonthData>((event, emit) async {
      final Map<DateTime, List<HeadacheIntensity>> intensities = {};

      DateTime firstDayOfMonth =
          DateTime(event.month.year, event.month.month, 1);
      DateTime lastDayOfMonth =
          DateTime(event.month.year, event.month.month + 1, 0);

      for (DateTime date = firstDayOfMonth;
          date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);

        final hasLogs =
            await headacheLogRepository.hasLogsForDay(normalizedDate);
        if (hasLogs) {
          final dayIntensities = await headacheLogRepository
              .getHeadacheIntensitiesForDay(normalizedDate);
          intensities[normalizedDate] = dayIntensities;
        }
      }

      emit(state.copyWith(headacheIntensities: intensities));
    });
  }
}
