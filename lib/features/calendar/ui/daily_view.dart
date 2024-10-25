import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/calendar/bloc/calendar_event.dart';
import 'package:fray/features/headache_log/bloc/headache_log_event.dart';
import 'package:fray/features/headache_log/bloc/headache_log_state.dart';
import 'package:fray/features/headache_log/ui/headache_log_page.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/models/headache_log.dart';
import 'package:fray/repositories/headache_log_repository.dart';
import 'package:intl/intl.dart';

class DailyView extends StatefulWidget {
  const DailyView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
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

    final startOfDay =
        DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    _headacheLogBloc!.add(GetHeadacheLogsForDateRange(startOfDay, endOfDay));
  }

  void _previousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
      _loadHeadacheLogs();
    });
  }

  void _nextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
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

    return BlocProvider(
      create: (context) => _headacheLogBloc!,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: BlocBuilder<HeadacheLogBloc, HeadacheLogState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.errorMessage != null) {
                  return Center(child: Text(state.errorMessage!));
                } else if (state.headacheLogs != null &&
                    state.headacheLogs!.isNotEmpty) {
                  return _buildLogs(state.headacheLogs!);
                } else {
                  return _buildLogs([]);
                }
              },
            ),
          ),
        ],
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
