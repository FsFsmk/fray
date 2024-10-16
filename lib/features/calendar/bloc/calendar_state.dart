import 'package:equatable/equatable.dart';
import 'package:fray/models/headache_enum.dart';

class CalendarState extends Equatable {
  final DateTime? selectedDay;
  final bool hasHeadacheLogs;
  final Map<DateTime, List<HeadacheIntensity>> headacheIntensities;

  const CalendarState({
    required this.selectedDay,
    required this.hasHeadacheLogs,
    required this.headacheIntensities,
  });

  @override
  List<Object?> get props => [selectedDay, hasHeadacheLogs];

  CalendarState copyWith(
      {DateTime? selectedDay,
      bool? hasHeadacheLogs,
      Map<DateTime, List<HeadacheIntensity>>? headacheIntensities}) {
    return CalendarState(
      selectedDay: selectedDay ?? this.selectedDay,
      hasHeadacheLogs: hasHeadacheLogs ?? this.hasHeadacheLogs,
      headacheIntensities: headacheIntensities ?? this.headacheIntensities,
    );
  }
}
