import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/calendar/bloc/calendar_event.dart';
import 'package:fray/features/calendar/bloc/calendar_state.dart';
import 'package:fray/features/headache_log/ui/headache_log_page.dart';
import 'package:intl/intl.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:gap/gap.dart';

class MonthlyCalendarView extends StatefulWidget {
  final DateTime initialDateTime;

  const MonthlyCalendarView({super.key, required this.initialDateTime});

  @override
  State<StatefulWidget> createState() => MonthlyCalendarViewState();
}

class MonthlyCalendarViewState extends State<MonthlyCalendarView> {
  late DateTime currentMonth;
  late List<DateTime> datesGrid;

  @override
  void initState() {
    super.initState();
    currentMonth = widget.initialDateTime;
    datesGrid = _generateDatesGrid(currentMonth);
  }

  List<DateTime> _generateDatesGrid(DateTime month) {
    int numDays = DateTime(month.year, month.month + 1, 0).day;
    int firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    List<DateTime> dates = [];

    DateTime previousMonth = DateTime(month.year, month.month - 1);
    int previousMonthLastDay =
        DateTime(previousMonth.year, previousMonth.month + 1, 0).day;
    for (int i = firstWeekday; i > 0; i--) {
      dates.add(DateTime(previousMonth.year, previousMonth.month,
          previousMonthLastDay - i + 1));
    }

    // Fill current month's dates
    for (int day = 1; day <= numDays; day++) {
      dates.add(DateTime(month.year, month.month, day));
    }

    int remainingBoxes = 42 - dates.length; // 6 weeks * 7 days
    for (int day = 1; day <= remainingBoxes; day++) {
      dates.add(DateTime(month.year, month.month + 1, day));
    }

    return dates;
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
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => setState(() {
                    currentMonth =
                        DateTime(currentMonth.year, currentMonth.month - 1);
                    datesGrid = _generateDatesGrid(currentMonth);
                  }),
                ),
                Text(
                  DateFormat.yMMMM(Localizations.localeOf(context).toString())
                      .format(currentMonth),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => setState(() {
                    currentMonth =
                        DateTime(currentMonth.year, currentMonth.month + 1);
                    datesGrid = _generateDatesGrid(currentMonth);
                  }),
                ),
              ],
            ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  7,
                  (index) => Text(
                    DateFormat.E(Localizations.localeOf(context).toString())
                        .dateSymbols
                        .STANDALONEWEEKDAYS[index]
                        .substring(0, 3),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(12),
            Flexible(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                ),
                itemCount: datesGrid.length,
                itemBuilder: (context, index) {
                  DateTime date = datesGrid[index];
                  bool isCurrentMonth = date.month == currentMonth.month;
                  bool isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;

                  return GestureDetector(
                    onTap: () => _onDaySelected(date),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : isCurrentMonth
                                      ? Theme.of(context).colorScheme.surface
                                      : Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withOpacity(0.3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isToday
                                    ? Theme.of(context).colorScheme.primary
                                    : isCurrentMonth
                                        ? Theme.of(context).dividerColor
                                        : Theme.of(context)
                                            .dividerColor
                                            .withOpacity(0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: isToday
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : isCurrentMonth
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                          if (state.headacheIntensities.containsKey(date) &&
                              state.headacheIntensities[date]!.isNotEmpty)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getIntensityColor(
                                      state.headacheIntensities[date]!),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

Color _getIntensityColor(List<HeadacheIntensity> intensities) {
  HeadacheIntensity maxIntensity = intensities.reduce(
    (a, b) => a.index > b.index ? a : b,
  );
  return maxIntensity == HeadacheIntensity.severe
      ? Colors.red
      : maxIntensity == HeadacheIntensity.moderate
          ? Colors.orange
          : maxIntensity == HeadacheIntensity.mild
              ? Colors.yellow
              : Colors.transparent;
}
