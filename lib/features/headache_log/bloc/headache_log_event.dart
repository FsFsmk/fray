import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/headache_log/bloc/headache_log_state.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/models/headache_log.dart';
import 'package:fray/repositories/headache_log_repository.dart';

abstract class HeadacheLogEvent extends Equatable {
  const HeadacheLogEvent();

  @override
  List<Object?> get props => [];
}

class AddHeadacheLog extends HeadacheLogEvent {
  final HeadacheLog headacheLog;

  const AddHeadacheLog(
    this.headacheLog,
  );

  @override
  List<Object?> get props => [headacheLog];
}

class LoadHeadacheLog extends HeadacheLogEvent {
  final DateTime startTime;

  const LoadHeadacheLog(this.startTime);

  @override
  List<Object> get props => [startTime];
}

class RemoveHeadacheLog extends HeadacheLogEvent {
  final DateTime startTime;

  const RemoveHeadacheLog(this.startTime);

  @override
  List<Object> get props => [startTime];
}

class EditHeadacheLog extends HeadacheLogEvent {
  final HeadacheIntensity? intensity;
  final HeadacheLocation? headacheLocation;
  final HeadacheQuality? headacheQuality;
  final DateTime startTime;
  final DateTime? endTime;

  const EditHeadacheLog(
    this.intensity,
    this.headacheLocation,
    this.headacheQuality,
    this.startTime,
    this.endTime,
  );

  @override
  List<Object?> get props =>
      [intensity, headacheLocation, headacheQuality, startTime, endTime];
}

class GetHeadacheLogsForDay extends HeadacheLogEvent {
  final DateTime date;

  const GetHeadacheLogsForDay(this.date);

  @override
  List<Object> get props => [date];
}

class GetHeadacheLogsForDateRange extends HeadacheLogEvent {
  final DateTime startDate;
  final DateTime endDate;

  const GetHeadacheLogsForDateRange(this.startDate, this.endDate);

  @override
  List<Object> get props => [startDate, endDate];
}

class HeadacheLogBloc extends Bloc<HeadacheLogEvent, HeadacheLogState> {
  final HeadacheLogRepository formRepository;

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
        List<HeadacheLog> logs =
            formRepository.loadHeadacheLog(event.headacheLog.startTime);
        emit(state.copyWith(headacheLogs: logs));
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
        List<HeadacheLog> logs =
            formRepository.loadHeadacheLog(event.startTime);
        emit(state.copyWith(headacheLogs: logs));
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
        List<HeadacheLog> logs =
            formRepository.loadHeadacheLog(event.startTime);
        emit(state.copyWith(headacheLogs: logs));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load logs after editing: $e',
        ));
      }
    });

    on<LoadHeadacheLog>((event, emit) async {
      try {
        List<HeadacheLog> logs =
            formRepository.loadHeadacheLog(event.startTime);
        emit(state.copyWith(headacheLogs: logs, isLoading: false));
      } catch (e) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Failed to load logs: $e'));
      }
    });

    on<GetHeadacheLogsForDateRange>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final logs = await formRepository.getHeadacheLogsForDateRange(
            event.startDate, event.endDate);
        emit(state.copyWith(
            headacheLogs: logs, isLoading: false, errorMessage: null));
      } catch (e) {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Failed to load logs'));
      }
    });
  }
}
