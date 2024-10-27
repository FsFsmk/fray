import 'package:equatable/equatable.dart';

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

class LoadMonthData extends CalendarEvent {
  final DateTime month;

  const LoadMonthData(this.month);

  @override
  List<Object?> get props => [month];
}
