import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/calendar/bloc/calendar_state.dart';

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
  CalendarBloc() : super(const CalendarState(selectedDay: null)) {
    on<SelectDay>(
      (event, emit) {
        emit(state.copyWith(selectedDay: event.selectedDay));
      },
    );
  }
}
