import 'package:flutter/material.dart';
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
  late final SettingsState settingsState;
  late final HeadacheLogRepository headacheLogRepository;

  initRepo() async {
    headacheLogRepository = await HeadacheLogRepository.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initRepo();
    _calendarView = widget.settingsState.calendarView;
    settingsState = widget.settingsState;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                    ? MonthlyView(
                        settingsState: settingsState,
                      )
                    : _calendarView == CalendarView.weekly
                        ? WeeklyView(
                            settingsState: settingsState,
                          )
                        : DailyView(
                            settingsState: settingsState,
                          ),
              ),
            ),
          );
        },
      ),
    );
  }
}
