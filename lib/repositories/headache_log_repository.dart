import 'dart:convert';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/models/headache_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeadacheLogRepository {
  late final SharedPreferences _preferences;

  static HeadacheLogRepository? _instance;
  static Future<HeadacheLogRepository> getInstance() async {
    if (_instance == null) {
      _instance = HeadacheLogRepository._();
      await _instance!._initializePrefences();
    }
    return _instance!;
  }

  HeadacheLogRepository._();

  Future<void> _initializePrefences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> addHeadacheLog({
    required DateTime startTime,
    DateTime? endTime,
    required HeadacheIntensity intensity,
    required HeadacheLocation headacheLocation,
    required HeadacheQuality headacheQuality,
  }) async {
    final String dateKey = _formatDate(startTime);
    final String logId = startTime.millisecondsSinceEpoch.toString();
    final List<String> existingLogIds = await _getLogIdsForDay(dateKey);

    final newLog = HeadacheLog(
      headacheQuality: headacheQuality,
      intensity: intensity,
      headacheLocation: headacheLocation,
      startTime: startTime,
      endTime: endTime,
    );

    await _preferences.setString(logId, json.encode(newLog.toJson()));
    existingLogIds.add(logId);
    await _preferences.setString(dateKey, json.encode(existingLogIds));
  }

  List<HeadacheLog> loadHeadacheLog(DateTime startTime) {
    final String dateKey = _formatDate(startTime);
    final List<String> logIds = _getLogIdsForDaySync(dateKey);
    List<HeadacheLog> headacheLogs = [];

    for (String logId in logIds) {
      String? headacheLogJson = _preferences.getString(logId);
      if (headacheLogJson != null) {
        HeadacheLog headacheLogMap =
            HeadacheLog.fromJson(json.decode(headacheLogJson));
        HeadacheLog headacheFormState = HeadacheLog(
          startTime: headacheLogMap.startTime,
          endTime: headacheLogMap.endTime,
          headacheLocation: headacheLogMap.headacheLocation,
          headacheQuality: headacheLogMap.headacheQuality,
          intensity: headacheLogMap.intensity,
        );
        headacheLogs.add(headacheFormState);
      }
    }
    return headacheLogs;
  }

  Future<bool> hasLogsForDay(DateTime date) async {
    final String dateKey = _formatDate(date);
    final List<String> logIds = await _getLogIdsForDay(dateKey);
    return logIds.isNotEmpty;
  }

  Future<void> removeHeadacheLog(DateTime startTime) async {
    final String logId = startTime.millisecondsSinceEpoch.toString();
    final String dateKey = _formatDate(startTime);
    final List<String> existingLogIds = await _getLogIdsForDay(dateKey);

    existingLogIds.remove(logId);
    await _preferences.remove(logId);
    await _preferences.setString(dateKey, json.encode(existingLogIds));
  }

  Future<void> editHeadacheLog({
    required DateTime startTime,
    DateTime? endTime,
    HeadacheIntensity? intensity,
    HeadacheLocation? headacheLocation,
    HeadacheQuality? headacheQuality,
  }) async {
    final String logId = startTime.millisecondsSinceEpoch.toString();
    String? existingLogJson = _preferences.getString(logId);
    HeadacheLog updatedLog = existingLogJson != null
        ? HeadacheLog.fromJson(json.decode(existingLogJson))
        : throw Exception('Log not found');

    updatedLog.startTime = startTime;
    if (endTime != null) {
      updatedLog.endTime = endTime;
    }
    if (intensity != null) {
      updatedLog.intensity = intensity;
    }
    if (headacheLocation != null) {
      updatedLog.headacheLocation = headacheLocation;
    }
    if (headacheQuality != null) {
      updatedLog.headacheQuality = headacheQuality;
    }

    await _preferences.setString(logId, json.encode(updatedLog.toJson()));
  }

  Future<List<HeadacheLog>> getHeadacheLogsForDay(DateTime date) async {
    final String dateKey = _formatDate(date);
    final String? headacheLogIdsJson = _preferences.getString(dateKey);

    if (headacheLogIdsJson == null) return [];

    final List<String> headacheLogIds =
        List<String>.from(json.decode(headacheLogIdsJson));
    List<HeadacheLog> headacheLogs = [];

    for (String logId in headacheLogIds) {
      final dynamic logData = _preferences.get(logId);

      if (logData is String) {
        try {
          final Map<String, dynamic> logDataMap = json.decode(logData);
          headacheLogs.add(HeadacheLog.fromJson(logDataMap));
        } catch (e) {
          throw Exception('Error parsing log data for $logId: $e');
        }
      } else {
        throw Exception('Unexpected data type for logId $logId: $logData');
      }
    }

    return headacheLogs;
  }

  Future<List<HeadacheIntensity>> getHeadacheIntensitiesForDay(
      DateTime date) async {
    final List<HeadacheLog> logs = await getHeadacheLogsForDay(date);
    return logs.map<HeadacheIntensity>((log) {
      return log.intensity;
    }).toList();
  }

  Future<List<HeadacheLog>> getHeadacheLogsForDateRange(
      DateTime startDate, DateTime endDate) async {
    List<HeadacheLog> logsInRange = [];

    for (DateTime date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      final List<HeadacheLog> dailyLogs = await getHeadacheLogsForDay(date);

      logsInRange.addAll(dailyLogs);
    }

    return logsInRange;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<List<String>> _getLogIdsForDay(String dateKey) async {
    final String? logIdsJson = _preferences.getString(dateKey);
    if (logIdsJson == null) return [];
    return List<String>.from(json.decode(logIdsJson));
  }

  List<String> _getLogIdsForDaySync(String dateKey) {
    final String? logIdsJson = _preferences.getString(dateKey);
    if (logIdsJson == null) return [];
    return List<String>.from(json.decode(logIdsJson));
  }
}
