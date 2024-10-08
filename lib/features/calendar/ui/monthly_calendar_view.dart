import 'package:flutter/material.dart';

class MonthlyCalendarView extends StatelessWidget {
  const MonthlyCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

Color _getIntensityColor(List<int> intensities) {
  int maxIntensity = intensities.reduce((a, b) => a > b ? a : b);
  return maxIntensity >= 3
      ? Colors.red
      : maxIntensity == 2
          ? Colors.orange
          : Colors.yellow;
}
