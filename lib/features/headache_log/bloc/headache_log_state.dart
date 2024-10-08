import 'package:equatable/equatable.dart';
import 'package:fray/models/headache_enum.dart';

class HeadacheLogState extends Equatable {
  final DateTime startTime;
  final DateTime? endTime;
  final HeadacheIntensity intensity;
  final HeadacheLocation headacheLocation;
  final HeadacheQuality headacheQuality;

  const HeadacheLogState({
    required this.startTime,
    this.endTime,
    required this.intensity,
    required this.headacheLocation,
    required this.headacheQuality,
  });

  HeadacheLogState copyWith({
    DateTime? startTime,
    DateTime? endTime,
    HeadacheIntensity? intensity,
    HeadacheLocation? headacheLocation,
    HeadacheQuality? headacheQuality,
  }) {
    return HeadacheLogState(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      intensity: intensity ?? this.intensity,
      headacheLocation: headacheLocation ?? this.headacheLocation,
      headacheQuality: headacheQuality ?? this.headacheQuality,
    );
  }

  @override
  List<Object?> get props =>
      [startTime, endTime, intensity, headacheLocation, headacheQuality];
}
