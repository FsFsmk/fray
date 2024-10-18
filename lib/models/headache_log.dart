import 'package:fray/models/headache_enum.dart';

class HeadacheLog {
  HeadacheLocation headacheLocation;
  HeadacheQuality headacheQuality;
  HeadacheIntensity intensity;
  DateTime startTime;
  DateTime? endTime;

  HeadacheLog({
    required this.headacheQuality,
    required this.intensity,
    required this.headacheLocation,
    required this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'headacheLocation': headacheLocation.toString(),
      'headacheQuality': headacheQuality.toString(),
      'intensity': intensity.toString(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  factory HeadacheLog.fromJson(Map<String, dynamic> json) {
    return HeadacheLog(
      headacheLocation: HeadacheLocation.values
          .firstWhere((e) => e.toString() == json['headacheLocation']),
      headacheQuality: HeadacheQuality.values
          .firstWhere((e) => e.toString() == json['headacheQuality']),
      intensity: HeadacheIntensity.values
          .firstWhere((e) => e.toString() == json['intensity']),
      startTime: json['startTime'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['startTime'])
          : DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null
          ? (json['endTime'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['endTime'])
              : DateTime.parse(json['endTime']))
          : null,
    );
  }
}
