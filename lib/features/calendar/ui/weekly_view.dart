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

class WeeklyView extends StatefulWidget {
  final SettingsState settingsState;
  const WeeklyView({
    super.key,
    required this.settingsState,
  });

  @override
  State<StatefulWidget> createState() => _WeeklyViewState();
}

class _WeeklyViewState extends State<WeeklyView> {
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
    _loadWeekData(_currentDate);
    setState(() {
      _isInitialized = true;
    });
  }

  void _loadWeekData(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    DateTimeRange dateRange = DateTimeRange(start: startOfWeek, end: endOfWeek);
    _calendarBloc.add(LoadData(dateRange));
  }

  void _previousWeek() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 7));
      _loadWeekData(_currentDate);
    });
  }

  void _nextWeek() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 7));
      _loadWeekData(_currentDate);
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
              _loadWeekData(_currentDate);
            },
          ),
        ],
        child: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            final startOfWeek =
                _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
            final daysOfWeek = List.generate(
                7, (index) => startOfWeek.add(Duration(days: index)));

            return Column(
              children: [
                _buildHeader(daysOfWeek),
                Expanded(
                  child: _buildLogs(state.logs, daysOfWeek),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(List<DateTime> daysOfWeek) {
    final startOfWeek = daysOfWeek.first;
    final endOfWeek = daysOfWeek.last;

    final weekRangeText =
        '${DateFormat.MMMd().format(startOfWeek)} - ${DateFormat.MMMd().format(endOfWeek)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousWeek,
        ),
        Text(
          weekRangeText,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _nextWeek,
        ),
      ],
    );
  }

  Widget _buildLogs(List<HeadacheLog> logs, List<DateTime> daysOfWeek) {
    return ListView.builder(
      itemCount: daysOfWeek.length,
      itemBuilder: (context, index) {
        final day = daysOfWeek[index];
        final isToday = DateTime.now().year == day.year &&
            DateTime.now().month == day.month &&
            DateTime.now().day == day.day;

        final dailyLogs = logs.where((log) {
          final logDate = log.startTime;
          return logDate.year == day.year &&
              logDate.month == day.month &&
              logDate.day == day.day;
        }).toList();

        return GestureDetector(
          onTap: () => _onDaySelected(day),
          child: Card(
            color: isToday
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.EEEE().format(day),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isToday
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat.yMMMd().format(day),
                    style: TextStyle(
                      color: isToday
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (dailyLogs.isNotEmpty)
                    ...dailyLogs.map((log) => _buildLogItem(log))
                  else
                    Text(
                      'No logs available for this day.',
                      style: TextStyle(
                        color: isToday
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
        const Icon(Icons.circle, size: 8),
        Expanded(
          child: Container(
            height: 2,
            color: intensityColor,
          ),
        ),
        end != null
            ? const Icon(Icons.circle, size: 8)
            : const Icon(Icons.arrow_forward, size: 8),
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
