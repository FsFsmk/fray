import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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

class LoadData extends CalendarEvent {
  final DateTimeRange dateRange;

  const LoadData(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}
