import 'package:equatable/equatable.dart';
import 'package:fray/models/headache_enum.dart';

class HeadacheLogState extends Equatable {
  final DateTime startTime;
  final DateTime? endTime;
  final HeadacheIntensity intensity;
  final HeadacheLocation headacheLocation;
  final HeadacheQuality headacheQuality;
  final List<Map<String, dynamic>>? headacheLogs;
  final bool isLoading;
  final String? errorMessage;

  const HeadacheLogState({
    required this.startTime,
    this.endTime,
    required this.intensity,
    required this.headacheLocation,
    required this.headacheQuality,
    this.headacheLogs,
    this.isLoading = false,
    this.errorMessage,
  });

  HeadacheLogState copyWith({
    DateTime? startTime,
    DateTime? endTime,
    HeadacheIntensity? intensity,
    HeadacheLocation? headacheLocation,
    HeadacheQuality? headacheQuality,
    List<Map<String, dynamic>>? headacheLogs,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HeadacheLogState(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      intensity: intensity ?? this.intensity,
      headacheLocation: headacheLocation ?? this.headacheLocation,
      headacheQuality: headacheQuality ?? this.headacheQuality,
      headacheLogs: headacheLogs ?? this.headacheLogs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        intensity,
        headacheLocation,
        headacheQuality,
        headacheLogs,
        isLoading,
        errorMessage,
      ];
}
