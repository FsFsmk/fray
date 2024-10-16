import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/calendar/bloc/calendar_state.dart';
import 'package:fray/repositories/headache_log_repository.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class SelectDay extends CalendarEvent {
  final DateTime selectedDay;

  const SelectDay(this.selectedDay);

  @override
  List<Object?> get props => [selectedDay];
}

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
      final intensities = await headacheLogRepository
          .getHeadacheIntensitiesForDay(event.selectedDay);
      emit(state.copyWith(
        selectedDay: event.selectedDay,
        hasHeadacheLogs: hasLogs,
        headacheIntensities: {
          ...state.headacheIntensities,
          event.selectedDay: intensities,
        },
      ));
    });
  }
}
