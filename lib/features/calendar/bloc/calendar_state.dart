import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/models/headache_log.dart';

class CalendarState extends Equatable {
  final DateTime? selectedDay;
  final bool hasHeadacheLogs;
  final Map<DateTime, List<HeadacheIntensity>> headacheIntensities;
  final List<HeadacheLog> logs;
  final DateTimeRange currentDateRange;

  const CalendarState({
    this.selectedDay,
    required this.hasHeadacheLogs,
    required this.headacheIntensities,
    required this.logs,
    required this.currentDateRange,
  });

  @override
  List<Object?> get props => [
        selectedDay,
        hasHeadacheLogs,
        headacheIntensities,
        logs,
        currentDateRange
      ];

  CalendarState copyWith({
    DateTime? selectedDay,
    bool? hasHeadacheLogs,
    Map<DateTime, List<HeadacheIntensity>>? headacheIntensities,
    List<HeadacheLog>? logs,
    DateTimeRange? currentDateRange,
  }) {
    return CalendarState(
      selectedDay: selectedDay ?? this.selectedDay,
      hasHeadacheLogs: hasHeadacheLogs ?? this.hasHeadacheLogs,
      headacheIntensities: headacheIntensities ?? this.headacheIntensities,
      logs: logs ?? this.logs,
      currentDateRange: currentDateRange ?? this.currentDateRange,
    );
  }
}
