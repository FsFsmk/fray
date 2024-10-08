import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fray/features/headache_log/bloc/headache_log_state.dart';
import 'package:fray/models/headache_enum.dart';
import 'package:fray/repositories/headache_log_repository.dart';

abstract class HeadacheLogEvent extends Equatable {
  const HeadacheLogEvent();

  @override
  List<Object?> get props => [];
}

class AddHeadacheLog extends HeadacheLogEvent {
  final HeadacheIntensity intensity;
  final HeadacheLocation headacheLocation;
  final HeadacheQuality headacheQuality;
  final DateTime startTime;
  final DateTime? endTime;

  const AddHeadacheLog(
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
  final DateTime? startTime;
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
        startTime: event.startTime,
        endTime: event.endTime,
        intensity: event.intensity,
        headacheLocation: event.headacheLocation,
        headacheQuality: event.headacheQuality,
      );
      emit(state.copyWith());
    });

    on<LoadHeadacheLog>((event, emit) async {
      formRepository.loadHeadacheLog(event.startTime);
      emit(state.copyWith());
    });

    on<RemoveHeadacheLog>((event, emit) {
      formRepository.removeHeadacheLog(event.startTime);
      emit(state.copyWith());
    });

    on<EditHeadacheLog>((event, emit) async {
      await formRepository.editHeadacheLog(
        startTime: event.startTime!,
        endTime: event.endTime,
        intensity: event.intensity,
        headacheLocation: event.headacheLocation,
        headacheQuality: event.headacheQuality,
      );
      emit(state.copyWith());
    });
  }
}
