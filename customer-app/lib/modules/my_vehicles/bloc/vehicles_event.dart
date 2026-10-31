part of 'vehicles_bloc.dart';

@immutable
abstract class VehiclesEvent {}

class GetVehicles extends VehiclesEvent {}

class CreateNewCar extends VehiclesEvent {
  final BuildContext context;
  final String brand;
  final String model;
  final String plateNumber;
  final String color;
  final String carImage;

  CreateNewCar({
    required this.context,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.color,
    required this.carImage,
  });
}

class UpdateCar extends VehiclesEvent {
  final BuildContext context;
  final String id;
  final String brand;
  final String model;
  final String plateNumber;
  final String color;
  final String carImage;

  UpdateCar({
    required this.context,
    required this.id,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.color,
    required this.carImage,
  });
}

class DeleteCar extends VehiclesEvent {
  final String id;
  final int index;

  DeleteCar({required this.id, required this.index});
}

class SelectCar extends VehiclesEvent {
  final VehiclesModel vehicle;

  SelectCar({required this.vehicle});
}
