import 'package:equatable/equatable.dart';
import 'package:fray/models/headache_enum.dart';

abstract class HeadacheLogEvent extends Equatable {
  const HeadacheLogEvent();

  @override
  List<Object?> get props => [];
}

class AddHeadacheLog extends HeadacheLogEvent {
  final HeadacheIntensity intensity;
  final HeadacheLocation headacheLocation;
  final HeadacheQuality headacheQuality;
  final DateTime startTime;
  final DateTime? endTime;

  const AddHeadacheLog(
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
  final DateTime? startTime;
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
