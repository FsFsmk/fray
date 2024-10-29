import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/calendar/bloc/calendar_bloc.dart';
import 'package:fray/features/calendar/bloc/calendar_event.dart';
import 'package:fray/features/calendar/bloc/calendar_state.dart';
import 'package:fray/features/headache_log/bloc/headache_log_bloc.dart';
import 'package:fray/features/headache_log/bloc/headache_log_state.dart';
import 'package:fray/features/headache_log/ui/headache_log_page.dart';
import 'package:fray/features/settings/bloc/settings_state.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/models/headache_log.dart';
import 'package:fray/repositories/headache_log_repository.dart';
import 'package:intl/intl.dart';

class DailyView extends StatefulWidget {
  final SettingsState settingsState;

  const DailyView({
    super.key,
    required this.settingsState,
  });

  @override
  State<StatefulWidget> createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
  DateTime _currentDate = DateTime.now();
  late HeadacheLogRepository headacheLogRepository;
  late HeadacheLogBloc _headacheLogBloc;
  late CalendarBloc _calendarBloc;
  bool _isInitialized = false;
  late final SettingsState settingsState;

  @override
  void initState() {
    super.initState();
    _initializeBlocs();
    settingsState = widget.settingsState;
  }

  Future<void> _initializeBlocs() async {
    headacheLogRepository = await HeadacheLogRepository.getInstance();
    _headacheLogBloc = HeadacheLogBloc(formRepository: headacheLogRepository);
    _calendarBloc = CalendarBloc(
      headacheLogRepository: headacheLogRepository,
      updateStream: _headacheLogBloc.updateController.stream,
      settingsState: settingsState,
    );
    _loadDayData(_currentDate);
    setState(() {
      _isInitialized = true;
    });
  }

  void _loadDayData(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    DateTimeRange dateRange = DateTimeRange(start: startOfDay, end: endOfDay);
    _calendarBloc.add(LoadData(dateRange));
  }

  void _previousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
      _loadDayData(_currentDate);
    });
  }

  void _nextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
      _loadDayData(_currentDate);
    });
  }

  void _onDaySelected(DateTime date) {
    _calendarBloc.add(SelectDay(date));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HeadacheLogPage(
          selectedDate: date,
          hasLogs: _calendarBloc.state.hasHeadacheLogs,
          headacheLogBloc: _headacheLogBloc,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<CalendarBloc>.value(value: _calendarBloc),
        BlocProvider<HeadacheLogBloc>.value(value: _headacheLogBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<HeadacheLogBloc, HeadacheLogState>(
            listenWhen: (previous, current) =>
                previous.headacheLogs != current.headacheLogs,
            listener: (context, state) {
              _loadDayData(_currentDate);
            },
          ),
        ],
        child: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildLogs(state.logs),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final dateText = DateFormat.yMMMMEEEEd().format(_currentDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousDay,
        ),
        Text(
          dateText,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _nextDay,
        ),
      ],
    );
  }

  Widget _buildLogs(List<HeadacheLog> logs) {
    final isToday = DateTime.now().year == _currentDate.year &&
        DateTime.now().month == _currentDate.month &&
        DateTime.now().day == _currentDate.day;

    return GestureDetector(
      onTap: () => _onDaySelected(_currentDate),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
        child: Card(
          color: isToday
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          margin: const EdgeInsets.all(0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: logs.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: logs.map((log) => _buildLogItem(log)).toList(),
                  )
                : Text(
                    'No logs available for this day.',
                    style: TextStyle(
                      color: isToday
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogItem(HeadacheLog log) {
    final startTime = log.startTime;
    final endTime = log.endTime;
    final intensity = log.intensity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat.jm().format(startTime),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                endTime != null ? DateFormat.jm().format(endTime) : 'Ongoing',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: _buildTimeline(startTime, endTime, intensity),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTimeline(
      DateTime start, DateTime? end, HeadacheIntensity intensity) {
    final intensityColor = _getIntensityColor(intensity);
    return Row(
      children: [
        const Icon(Icons.circle, size: 8, color: Colors.grey),
        Expanded(
          child: Container(
            height: 2,
            color: intensityColor,
          ),
        ),
        end != null
            ? const Icon(Icons.circle, size: 8, color: Colors.grey)
            : const Icon(Icons.arrow_forward, size: 8, color: Colors.grey),
      ],
    );
  }
}

Color _getIntensityColor(HeadacheIntensity intensity) {
  return intensity == HeadacheIntensity.severe
      ? Colors.red
      : intensity == HeadacheIntensity.moderate
          ? Colors.orange
          : intensity == HeadacheIntensity.mild
              ? Colors.yellow
              : Colors.transparent;
}
