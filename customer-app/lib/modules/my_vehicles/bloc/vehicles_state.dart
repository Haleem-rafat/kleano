part of 'vehicles_bloc.dart';

@immutable
abstract class VehiclesState {}

class VehiclesInitial extends VehiclesState {}

class GetVehiclesLoading extends VehiclesState {}

class GetVehiclesEmpty extends VehiclesState {}

class GetVehiclesSuccess extends VehiclesState {
  final List<VehiclesModel> vehiclesList;

  GetVehiclesSuccess({required this.vehiclesList});
}

class GetVehiclesError extends VehiclesState {
  final String? error;

  GetVehiclesError({this.error});
}


class CreateNewCarLoading extends VehiclesState {}

class CreateNewCarSuccess extends VehiclesState {}

class CreateNewCarError extends VehiclesState {
  final String? error;

  CreateNewCarError({this.error});
}

class UpdateCarLoading extends VehiclesState {}

class UpdateCarSuccess extends VehiclesState {}

class UpdateCarError extends VehiclesState {
  final String? error;

  UpdateCarError({this.error});
}

class DeleteCarLoading extends VehiclesState {}

class DeleteCarSuccess extends VehiclesState {}

class DeleteCarError extends VehiclesState {
  final String? error;

  DeleteCarError({this.error});
}

class SelectCarLoading extends VehiclesState {}

class SelectCarSuccess extends VehiclesState {}

class SelectCarError extends VehiclesState {
  final String? error;

  SelectCarError({this.error});
}