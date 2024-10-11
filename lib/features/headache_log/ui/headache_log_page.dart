import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeadacheLogPage extends StatelessWidget {
  final DateTime selectedDate;

  const HeadacheLogPage({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat.yMMMMd(Localizations.localeOf(context).toString())
              .format(selectedDate),
        ),
      ),
      body: const Center(
        child: Text(
          'Options: View existing logs or add a new headache log for this day.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
