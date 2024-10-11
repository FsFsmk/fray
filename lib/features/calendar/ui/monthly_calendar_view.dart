import 'package:flutter/material.dart';
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

    // Fill previous month's dates
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

    // Fill next month's dates
    int remainingBoxes = 42 - dates.length; // 6 weeks * 7 days
    for (int day = 1; day <= remainingBoxes; day++) {
      dates.add(DateTime(month.year, month.month + 1, day));
    }

    return dates;
  }

  void _onDaySelected(DateTime date) {
    // Navigate to HeadacheLogPage with options to view or add a headache log
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HeadacheLogPage(selectedDate: date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              '${DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(currentMonth)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? Theme.of(context)
                              .colorScheme
                              .primary // Highlight today's date
                          : isCurrentMonth
                              ? Theme.of(context)
                                  .colorScheme
                                  .surface // Current month's days
                              : Theme.of(context)
                                  .colorScheme
                                  .background, // Other month's days
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday
                            ? Theme.of(context)
                                .colorScheme
                                .primary // Border for today
                            : isCurrentMonth
                                ? Theme.of(context)
                                    .dividerColor // current month border
                                : Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.3), // Other month border
                      ),
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: isToday
                              ? Theme.of(context)
                                  .colorScheme
                                  .onPrimary // Text color for today
                              : isCurrentMonth
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurface // Current month text
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.3), // Other month text
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
