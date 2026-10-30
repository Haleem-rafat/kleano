part of 'point_bloc.dart';

@immutable
abstract class PointState {}

class PointInitial extends PointState {}

class PointLoading extends PointState {}

class PointLoaded extends PointState {
  final PointModel pointResponse;

  PointLoaded({required this.pointResponse});
}

class PointFailed extends PointState {
  final String error;

  PointFailed({required this.error});
}

class ApplyPointsLoading extends PointState {}

class ApplyPointsSuccess extends PointState {
  final ApplyPoint applyPointModel;

  ApplyPointsSuccess({required this.applyPointModel});
}

class ApplyPointsFailed extends PointState {
  final String? error;
  final ErrorModel? errorModel;

  ApplyPointsFailed({
    this.error,
    this.errorModel,
  });
}
