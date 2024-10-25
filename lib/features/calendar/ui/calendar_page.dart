import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/calendar/bloc/calendar_event.dart';
import 'package:fray/features/calendar/ui/daily_view.dart';
import 'package:fray/features/calendar/ui/monthly_view.dart';
import 'package:fray/features/calendar/ui/weekly_view.dart';
import 'package:fray/features/settings/bloc/settings_state.dart';
import 'package:fray/models/settings_enum.dart';
import 'package:fray/repositories/headache_log_repository.dart';

class CalendarPage extends StatefulWidget {
  final SettingsState settingsState;

  const CalendarPage({
    super.key,
    required this.settingsState,
  });

  @override
  State<StatefulWidget> createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  late final CalendarView _calendarView;
  late final HeadacheLogRepository headacheLogRepository;

  initRepo() async {
    headacheLogRepository = await HeadacheLogRepository.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initRepo();
    _calendarView = widget.settingsState.calendarView;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalendarBloc(
        headacheLogRepository: headacheLogRepository,
      ),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double dynamicHeight = constraints.maxHeight * 0.7;
            return Card(
              elevation: 8.0,
              shadowColor: Colors.black.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: dynamicHeight,
                  child: _calendarView == CalendarView.monthly
                      ? const MonthlyView()
                      : _calendarView == CalendarView.weekly
                          ? const WeeklyView()
                          : const DailyView(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
