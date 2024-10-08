import 'package:flutter/material.dart';
import 'package:fray/features/calendar/ui/daily_view.dart';
import 'package:fray/features/calendar/ui/monthly_calendar_view.dart';
import 'package:fray/features/calendar/ui/weekly_view.dart';
import 'package:fray/features/settings/bloc/settings_state.dart';
import 'package:fray/models/settings_enum.dart';

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

  @override
  void initState() {
    super.initState();
    _calendarView = widget.settingsState.calendarView;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: _calendarView == CalendarView.monthly
          ? const MonthlyCalendarView()
          : _calendarView == CalendarView.weekly
              ? const WeeklyView()
              : const DailyView(),
    );
  }
}
