import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/headache_log/bloc/headache_log_event.dart';
import 'package:fray/features/headache_log/bloc/headache_log_state.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/repositories/headache_log_repository.dart';

class HeadacheLogBloc extends Bloc<HeadacheLogEvent, HeadacheLogState> {
  final HeadacheLogRepository formRepository;
  final StreamController<DateTime> updateController =
      StreamController<DateTime>.broadcast();

  HeadacheLogBloc({required this.formRepository})
      : super(
          HeadacheLogState(
            startTime: DateTime.fromMillisecondsSinceEpoch(0),
            intensity: HeadacheIntensity.unspecified,
            headacheLocation: HeadacheLocation.unspecified,
            headacheQuality: HeadacheQuality.unspecified,
          ),
        ) {
    on<AddHeadacheLog>((event, emit) async {
      await formRepository.addHeadacheLog(
        startTime: event.headacheLog.startTime,
        endTime: event.headacheLog.endTime,
        intensity: event.headacheLog.intensity,
        headacheLocation: event.headacheLog.headacheLocation,
        headacheQuality: event.headacheLog.headacheQuality,
      );
      try {
        final logs = await formRepository
            .getHeadacheLogsForDay(event.headacheLog.startTime);
        emit(state.copyWith(headacheLogs: logs));

        _broadcastUpdate(event.headacheLog.startTime);
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load logs after addition: $e',
        ));
      }
    });

    on<RemoveHeadacheLog>((event, emit) async {
      await formRepository.removeHeadacheLog(event.startTime);
      try {
        final logs =
            await formRepository.getHeadacheLogsForDay(event.startTime);
        emit(state.copyWith(headacheLogs: logs));

        _broadcastUpdate(event.startTime);
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load logs after deletion: $e',
        ));
      }
    });

    on<EditHeadacheLog>((event, emit) async {
      await formRepository.editHeadacheLog(
        startTime: event.startTime,
        endTime: event.endTime,
        intensity: event.intensity,
        headacheLocation: event.headacheLocation,
        headacheQuality: event.headacheQuality,
      );
      try {
        final logs =
            await formRepository.getHeadacheLogsForDay(event.startTime);
        emit(state.copyWith(headacheLogs: logs));

        _broadcastUpdate(event.startTime);
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load logs after editing: $e',
        ));
      }
    });

    on<LoadHeadacheLog>((event, emit) async {
      try {
        final logs =
            await formRepository.getHeadacheLogsForDay(event.startTime);
        emit(state.copyWith(headacheLogs: logs, isLoading: false));
      } catch (e) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Failed to load logs: $e'));
      }
    });
  }

  void _broadcastUpdate(DateTime date) {
    updateController.sink.add(date);
  }

  @override
  Future<void> close() {
    updateController.close();
    return super.close();
  }
}
