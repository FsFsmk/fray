import 'package:equatable/equatable.dart';

class CalendarState extends Equatable {
  final DateTime? selectedDay;

  const CalendarState({required this.selectedDay});

  @override
  List<Object?> get props => [selectedDay];

  CalendarState copyWith({DateTime? selectedDay}) {
    return CalendarState(selectedDay: selectedDay ?? this.selectedDay);
  }
}
