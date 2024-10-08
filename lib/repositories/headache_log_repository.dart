import 'dart:convert';
import 'package:fray/features/headache_log/bloc/headache_log_state.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeadacheLogRepository {
  late final SharedPreferences _preferences;

  Future<void> addHeadacheLog({
    required DateTime startTime,
    DateTime? endTime,
    required HeadacheIntensity intensity,
    required HeadacheLocation headacheLocation,
    required HeadacheQuality headacheQuality,
  }) async {
    await _preferences.setString(
      '${startTime.millisecondsSinceEpoch}',
      json.encode(
        HeadacheLogState(
          startTime: startTime,
          endTime: endTime,
          headacheLocation: headacheLocation,
          headacheQuality: headacheQuality,
          intensity: intensity,
        ),
      ),
    );
  }

  List<HeadacheLogState> loadHeadacheLog(DateTime startTime) {
    String headacheLogJson =
        _preferences.getString('${startTime.millisecondsSinceEpoch}') ?? '';

    List<HeadacheLogState> headacheLog = [];

    Map<String, dynamic> headacheLogMap = json.decode(headacheLogJson);

    if (headacheLogMap.isNotEmpty) {
      HeadacheLogState headacheFormState = HeadacheLogState(
        startTime: startTime,
        endTime: DateTime.fromMillisecondsSinceEpoch(
          int.parse(
            headacheLogMap['endTime'] ?? '0',
          ),
        ),
        headacheLocation: HeadacheLocation.values.firstWhere(
          (e) => e.toString() == headacheLogMap['headacheLocation'],
        ),
        headacheQuality: HeadacheQuality.values.firstWhere(
          (e) => e.toString() == headacheLogMap['headacheQuality'],
        ),
        intensity: HeadacheIntensity.values.firstWhere(
          (e) => e.toString() == headacheLogMap['intensity'],
        ),
      );
      headacheLog.add(headacheFormState);
    }
    return headacheLog;
  }

  Future<void> removeHeadacheLog(DateTime startTime) async {
    await _preferences.remove('${startTime.millisecondsSinceEpoch}');
  }

  Future<void> editHeadacheLog({
    required DateTime startTime,
    DateTime? endTime,
    HeadacheIntensity? intensity,
    HeadacheLocation? headacheLocation,
    HeadacheQuality? headacheQuality,
  }) async {
    await _preferences.setString(
      '${startTime.millisecondsSinceEpoch}',
      json.encode(
        HeadacheLogState(
          startTime: startTime,
          endTime: endTime,
          headacheLocation: headacheLocation!,
          headacheQuality: headacheQuality!,
          intensity: intensity!,
        ),
      ),
    );
  }
}
