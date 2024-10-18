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
}
