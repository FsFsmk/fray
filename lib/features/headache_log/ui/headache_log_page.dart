import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/repositories/headache_log_repository.dart';
import 'package:intl/intl.dart';
import 'package:fray/features/headache_log/bloc/headache_log_event.dart';
import 'package:fray/features/headache_log/bloc/headache_log_state.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/models/headache_log.dart';

class HeadacheLogPage extends StatefulWidget {
  final DateTime selectedDate;
  final bool hasLogs;

  const HeadacheLogPage({
    super.key,
    required this.selectedDate,
    required this.hasLogs,
  });

  @override
  State<StatefulWidget> createState() => _HeadacheLogPageState();
}

class _HeadacheLogPageState extends State<HeadacheLogPage> {
  late final HeadacheLogRepository headacheLogRepository;
  HeadacheLogBloc? _headacheLogBloc;

  Future<void> initRepo() async {
    headacheLogRepository = await HeadacheLogRepository.getInstance();
    setState(() {
      _headacheLogBloc = HeadacheLogBloc(formRepository: headacheLogRepository);
    });
  }

  @override
  void initState() {
    super.initState();
    initRepo();

    if (widget.hasLogs && _headacheLogBloc != null) {
      context.read<HeadacheLogBloc>().add(LoadHeadacheLog(widget.selectedDate));
    }
  }

  Future<DateTime?> showDateTimePicker(
      BuildContext context, DateTime initialDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat.yMMMMd(Localizations.localeOf(context).toString())
              .format(widget.selectedDate),
        ),
      ),
      body: widget.hasLogs
          ? BlocBuilder<HeadacheLogBloc, HeadacheLogState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.errorMessage != null) {
                  return Center(child: Text('Error: ${state.errorMessage}'));
                } else if (state.headacheLogs != null &&
                    state.headacheLogs!.isNotEmpty) {
                  return _buildLogOptions(state.headacheLogs!);
                } else {
                  return const Center(
                      child: Text('No logs found for this day.'));
                }
              },
            )
          : _buildNewLogOption(),
    );
  }

  Widget _buildLogOptions(List<HeadacheLog> logs) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return ListTile(
          title: Text('Log ${index + 1}'),
          subtitle: Text(
              'Intensity: ${log.intensity}, Location: ${log.headacheLocation}'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editLog(log),
          ),
          onLongPress: () => _deleteLog(log),
        );
      },
    );
  }

  Widget _buildNewLogOption() {
    return Center(
      child: ElevatedButton(
        onPressed: _addNewLog,
        child: const Text('Add New Headache Log'),
      ),
    );
  }

  Future<void> _addNewLog() async {
    HeadacheIntensity? intensity;
    HeadacheLocation? location;
    HeadacheQuality? quality;
    DateTime? startTime = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return BlocProvider(
          create: (context) => HeadacheLogBloc(
            formRepository: headacheLogRepository,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Add New Headache Log'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'Start Time: ${DateFormat.yMMMd().add_jm().format(startTime!)}'),
                    TextButton(
                      onPressed: () async {
                        final newStartTime =
                            await showDateTimePicker(context, startTime!);
                        if (newStartTime != null) {
                          setState(() {
                            startTime = newStartTime;
                          });
                        }
                      },
                      child: const Text('Change Start Time'),
                    ),
                    DropdownButton<HeadacheIntensity>(
                      hint: const Text('Select Intensity'),
                      value: intensity,
                      onChanged: (newIntensity) {
                        setState(() {
                          intensity = newIntensity!;
                        });
                      },
                      items: HeadacheIntensity.values.map((intensity) {
                        return DropdownMenuItem(
                          value: intensity,
                          child: Text(intensity.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                    DropdownButton<HeadacheLocation>(
                      hint: const Text('Select Location'),
                      value: location,
                      onChanged: (newLocation) {
                        setState(() {
                          location = newLocation!;
                        });
                      },
                      items: HeadacheLocation.values.map((location) {
                        return DropdownMenuItem(
                          value: location,
                          child: Text(location.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                    DropdownButton<HeadacheQuality>(
                      hint: const Text('Select Quality'),
                      value: quality,
                      onChanged: (newQuality) {
                        setState(() {
                          quality = newQuality!;
                        });
                      },
                      items: HeadacheQuality.values.map((quality) {
                        return DropdownMenuItem(
                          value: quality,
                          child: Text(quality.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (intensity != null &&
                          location != null &&
                          quality != null) {
                        final newLog = HeadacheLog(
                          headacheQuality: quality!,
                          intensity: intensity!,
                          headacheLocation: location!,
                          startTime: startTime!,
                        );

                        context
                            .read<HeadacheLogBloc>()
                            .add(AddHeadacheLog(newLog));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _editLog(HeadacheLog log) async {
    context.read<HeadacheLogBloc>().add(
          EditHeadacheLog(
            log.intensity,
            log.headacheLocation,
            log.headacheQuality,
            log.startTime,
            log.endTime,
          ),
        );
  }

  Future<void> _deleteLog(HeadacheLog log) async {
    context.read<HeadacheLogBloc>().add(RemoveHeadacheLog(log.startTime));
  }
}
