import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/calendar/bloc/calendar_event.dart';
import 'package:fray/features/headache_log/bloc/headache_log_event.dart';
import 'package:fray/features/headache_log/bloc/headache_log_state.dart';
import 'package:fray/features/headache_log/ui/headache_log_page.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/repositories/headache_log_repository.dart';
import 'package:intl/intl.dart';

class WeeklyView extends StatefulWidget {
  const WeeklyView({super.key});

  @override
  State<StatefulWidget> createState() => _WeeklyViewState();
}

class _WeeklyViewState extends State<WeeklyView> {
  DateTime _currentDate = DateTime.now();
  late HeadacheLogRepository headacheLogRepository;
  HeadacheLogBloc? _headacheLogBloc;
  bool _isInitialized = false;

  Future<void> initRepo() async {
    headacheLogRepository = await HeadacheLogRepository.getInstance();
    setState(() {
      _isInitialized = true;
      _headacheLogBloc = HeadacheLogBloc(formRepository: headacheLogRepository);
      _loadHeadacheLogs();
    });
  }

  @override
  void initState() {
    super.initState();
    initRepo();
  }

  void _loadHeadacheLogs() {
    if (_headacheLogBloc == null) return;

    final startOfWeek =
        _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    _headacheLogBloc!.add(GetHeadacheLogsForDateRange(startOfWeek, endOfWeek));
  }

  void _previousWeek() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 7));
      _loadHeadacheLogs();
    });
  }

  void _nextWeek() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 7));
      _loadHeadacheLogs();
    });
  }

  void _onDaySelected(DateTime date) {
    final calendarBloc = BlocProvider.of<CalendarBloc>(context);
    calendarBloc.add(SelectDay(date));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HeadacheLogPage(
          selectedDate: date,
          hasLogs: calendarBloc.state.hasHeadacheLogs,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final startOfWeek =
        _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
    final daysOfWeek =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return BlocProvider(
      create: (context) => _headacheLogBloc!,
      child: Column(
        children: [
          _buildHeader(daysOfWeek),
          Expanded(
            child: BlocBuilder<HeadacheLogBloc, HeadacheLogState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.errorMessage != null) {
                  return Center(child: Text(state.errorMessage!));
                } else if (state.headacheLogs != null &&
                    state.headacheLogs!.isNotEmpty) {
                  return _buildLogs(state.headacheLogs!, daysOfWeek);
                } else {
                  return _buildLogs([], daysOfWeek);
                }
              },
            ),
          ),
        ],
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

  Widget _buildLogs(
      List<Map<String, dynamic>> logs, List<DateTime> daysOfWeek) {
    return ListView.builder(
      itemCount: daysOfWeek.length,
      itemBuilder: (context, index) {
        final day = daysOfWeek[index];
        final isToday = DateTime.now().year == day.year &&
            DateTime.now().month == day.month &&
            DateTime.now().day == day.day;

        final dailyLogs = logs.where((log) {
          final logDate = log['start_time'] as DateTime;
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

  Widget _buildLogItem(Map<String, dynamic> log) {
    final startTime = log['start_time'] as DateTime;
    final endTime = log['end_time'] as DateTime?;
    final intensity = log['intensity'] as HeadacheIntensity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            '${DateFormat.jm().format(startTime)} - ${endTime != null ? DateFormat.jm().format(endTime) : 'Ongoing'}'),
        Row(
          children: [
            _buildTimeline(startTime, endTime, intensity),
          ],
        ),
      ],
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
