part of 'cars_bloc.dart';

abstract class CarsState extends Equatable {
  const CarsState();

  @override
  List<Object> get props => [];
}

class CarsInitial extends CarsState {}

class GetCarModelLoading extends CarsState {}

class GetCarModelSuccess extends CarsState {
  final List<String> carModel;

  const GetCarModelSuccess({required this.carModel});
}

class GetCarModelError extends CarsState {
  final String? error;

  const GetCarModelError({this.error});
}

class GetCarBrandsLoading extends CarsState {}

class GetCarBrandsSuccess extends CarsState {
  final List<CarBrandsModel> carBrands;

  const GetCarBrandsSuccess({required this.carBrands});
}

class GetCarBrandsError extends CarsState {
  final String? error;

  const GetCarBrandsError({this.error});
}

class GetCarModelByBrandIdSuccess extends CarsState {
  final List<String> carModels;

  const GetCarModelByBrandIdSuccess({required this.carModels});
}

class GetCarModelByBrandIdloading extends CarsState {

}


