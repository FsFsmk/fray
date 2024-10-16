import 'dart:convert';
import 'package:fray/features/headache_log/bloc/headache_log_state.dart';
import 'package:fray/models/headache_enum.dart';
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

    final Map<String, dynamic> newLog = {
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'intensity': intensity.toString(),
      'headacheLocation': headacheLocation.toString(),
      'headacheQuality': headacheQuality.toString(),
    };

    await _preferences.setString(logId, json.encode(newLog));
    existingLogIds.add(logId);
    await _preferences.setString(dateKey, json.encode(existingLogIds));
  }

  List<HeadacheLogState> loadHeadacheLog(DateTime startTime) {
    final String dateKey = _formatDate(startTime);
    final List<String> logIds = _getLogIdsForDaySync(dateKey);
    List<HeadacheLogState> headacheLogs = [];

    for (String logId in logIds) {
      String? headacheLogJson = _preferences.getString(logId);
      if (headacheLogJson != null) {
        Map<String, dynamic> headacheLogMap = json.decode(headacheLogJson);
        HeadacheLogState headacheFormState = HeadacheLogState(
          startTime:
              DateTime.fromMillisecondsSinceEpoch(headacheLogMap['startTime']),
          endTime: headacheLogMap['endTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(headacheLogMap['endTime'])
              : null,
          headacheLocation:
              HeadacheLocation.values[headacheLogMap['headacheLocation']],
          headacheQuality:
              HeadacheQuality.values[headacheLogMap['headacheQuality']],
          intensity: HeadacheIntensity.values[headacheLogMap['intensity']],
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
    Map<String, dynamic> updatedLog =
        existingLogJson != null ? json.decode(existingLogJson) : {};

    updatedLog['startTime'] = startTime.millisecondsSinceEpoch;
    if (endTime != null) {
      updatedLog['endTime'] = endTime.millisecondsSinceEpoch;
    }
    if (intensity != null) {
      updatedLog['intensity'] = intensity.index;
    }
    if (headacheLocation != null) {
      updatedLog['headacheLocation'] = headacheLocation.index;
    }
    if (headacheQuality != null) {
      updatedLog['headacheQuality'] = headacheQuality.index;
    }

    await _preferences.setString(logId, json.encode(updatedLog));
  }

  Future<List<Map<String, dynamic>>> getHeadacheLogsForDay(
      DateTime date) async {
    final String dateKey = _formatDate(date);
    final String? headacheLogIdsJson = _preferences.getString(dateKey);
    if (headacheLogIdsJson == null) return [];

    final List<String> headacheLogIds =
        List<String>.from(json.decode(headacheLogIdsJson));
    List<Map<String, dynamic>> headacheLogs = [];

    for (String logId in headacheLogIds) {
      final String? logDataJson = _preferences.getString(logId);
      if (logDataJson != null) {
        headacheLogs.add(json.decode(logDataJson));
      }
    }

    return headacheLogs;
  }

  Future<List<HeadacheIntensity>> getHeadacheIntensitiesForDay(
      DateTime date) async {
    final List<Map<String, dynamic>> logs = await getHeadacheLogsForDay(date);
    return logs.map<HeadacheIntensity>((log) {
      return HeadacheIntensity.values[log['intensity']];
    }).toList();
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
