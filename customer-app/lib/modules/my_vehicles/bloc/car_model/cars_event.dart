part of 'cars_bloc.dart';

abstract class CarsEvent extends Equatable {
  const CarsEvent();

  @override
  List<Object> get props => [];
}

class GetCarModel extends CarsEvent {}

class GetCarBrands extends CarsEvent {}

class GetCarModelByBrandId extends CarsEvent {
  final String brandId;

  const GetCarModelByBrandId({required this.brandId});
}
