import 'package:equatable/equatable.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/models/headache_log.dart';

abstract class HeadacheLogEvent extends Equatable {
  const HeadacheLogEvent();

  @override
  List<Object?> get props => [];
}

class AddHeadacheLog extends HeadacheLogEvent {
  final HeadacheLog headacheLog;

  const AddHeadacheLog(
    this.headacheLog,
  );

  @override
  List<Object?> get props => [headacheLog];
}

class LoadHeadacheLog extends HeadacheLogEvent {
  final DateTime startTime;

  const LoadHeadacheLog(this.startTime);

  @override
  List<Object> get props => [startTime];
}

class RemoveHeadacheLog extends HeadacheLogEvent {
  final DateTime startTime;

  const RemoveHeadacheLog(this.startTime);

  @override
  List<Object> get props => [startTime];
}

class EditHeadacheLog extends HeadacheLogEvent {
  final HeadacheIntensity? intensity;
  final HeadacheLocation? headacheLocation;
  final HeadacheQuality? headacheQuality;
  final DateTime startTime;
  final DateTime? endTime;

  const EditHeadacheLog(
    this.intensity,
    this.headacheLocation,
    this.headacheQuality,
    this.startTime,
    this.endTime,
  );

  @override
  List<Object?> get props =>
      [intensity, headacheLocation, headacheQuality, startTime, endTime];
}

class GetHeadacheLogsForDay extends HeadacheLogEvent {
  final DateTime date;

  const GetHeadacheLogsForDay(this.date);

  @override
  List<Object> get props => [date];
}

class GetHeadacheLogsForDateRange extends HeadacheLogEvent {
  final DateTime startDate;
  final DateTime endDate;

  const GetHeadacheLogsForDateRange(this.startDate, this.endDate);

  @override
  List<Object> get props => [startDate, endDate];
}
