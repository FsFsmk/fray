import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/headache_log/bloc/headache_log_bloc.dart';
import 'package:fray/repositories/headache_log_repository.dart';
import 'package:intl/intl.dart';
import 'package:fray/features/headache_log/bloc/headache_log_event.dart';
import 'package:fray/features/headache_log/bloc/headache_log_state.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/models/headache_log.dart';

class HeadacheLogPage extends StatefulWidget {
  final DateTime selectedDate;
  final bool hasLogs;
  final HeadacheLogBloc headacheLogBloc;

  const HeadacheLogPage({
    super.key,
    required this.selectedDate,
    required this.hasLogs,
    required this.headacheLogBloc,
  });

  @override
  State<HeadacheLogPage> createState() => _HeadacheLogPageState();
}

class _HeadacheLogPageState extends State<HeadacheLogPage> {
  late final HeadacheLogRepository headacheLogRepository;
  late final HeadacheLogBloc _headacheLogBloc;
  bool _isInitialized = false;

  Future<void> initRepo() async {
    headacheLogRepository = await HeadacheLogRepository.getInstance();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    initRepo();

    _headacheLogBloc = widget.headacheLogBloc;
    _headacheLogBloc.add(LoadHeadacheLog(widget.selectedDate));
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
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocProvider<HeadacheLogBloc>(
      create: (context) {
        if (widget.hasLogs) {
          _headacheLogBloc.add(LoadHeadacheLog(widget.selectedDate));
        }
        return _headacheLogBloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            DateFormat.yMMMMd(Localizations.localeOf(context).toString())
                .format(widget.selectedDate),
          ),
        ),
        body: BlocBuilder<HeadacheLogBloc, HeadacheLogState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.errorMessage != null) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            } else if (state.headacheLogs != null &&
                state.headacheLogs!.isNotEmpty) {
              return _buildLogOptions(state.headacheLogs!);
            } else {
              return const Text('No logs found for this day.');
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addNewLog(context, _headacheLogBloc),
          child: const Icon(Icons.add),
        ),
      ),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editLog(context, log),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDeleteLog(context, log),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addNewLog(BuildContext context, HeadacheLogBloc bloc) async {
    HeadacheIntensity? intensity;
    HeadacheLocation? location;
    HeadacheQuality? quality;
    DateTime? startTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      DateTime.now().hour,
      DateTime.now().minute,
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return AlertDialog(
              title: const Text('Add New Headache Log'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Start Time: ${DateFormat.yMMMd().add_jm().format(startTime!)}',
                    ),
                    TextButton(
                      onPressed: () async {
                        final newStartTime = await showDateTimePicker(
                          context,
                          startTime!,
                        );
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
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
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

                      bloc.add(AddHeadacheLog(newLog));
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editLog(BuildContext blocContext, HeadacheLog log) async {
// TODO: implement
  }

  void _confirmDeleteLog(BuildContext blocContext, HeadacheLog log) {
    showDialog(
      context: blocContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Log'),
          content: const Text('Are you sure you want to delete this log?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                blocContext
                    .read<HeadacheLogBloc>()
                    .add(RemoveHeadacheLog(log.startTime));
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
