import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:thewasher/modules/my_vehicles/data/model/car_model.dart';
import 'package:thewasher/repository/vehicles_repo.dart';

part 'cars_event.dart';
part 'cars_state.dart';

class CarsBloc extends Bloc<CarsEvent, CarsState> {
  CarsBloc() : super(CarsInitial()) {
    on<GetCarModel>((GetCarModel event, Emitter<CarsState> emit) async {
      try {
        print("done1");
        print("Get Car Model");
        emit(GetCarModelLoading());
        final List<String> response = await VehiclesRepo.getCarModel();
        if (response.isNotEmpty) {
          emit(GetCarModelSuccess(carModel: response));
        } else {
          emit(GetCarModelError(error: "Error"));
        }
      } catch (e) {
        emit(GetCarModelError(error: e.toString()));
      }
    });
    on<GetCarBrands>((GetCarBrands event, Emitter<CarsState> emit) async {
      try {
        print("done2");
        print("Get Car Brands");
        emit(GetCarBrandsLoading());
        final List<CarBrandsModel> response = await VehiclesRepo.getCarBrands();
        if (response.isNotEmpty) {
          emit(GetCarBrandsSuccess(carBrands: response));
        } else {
          emit(GetCarBrandsError(error: "Error"));
        }
      } catch (e) {
        emit(GetCarBrandsError(error: e.toString()));
      }
    });

    on<GetCarModelByBrandId>(
        (GetCarModelByBrandId event, Emitter<CarsState> emit) async {
      try {
        emit(GetCarModelByBrandIdloading());
        final List<String> response =
            await VehiclesRepo.getCarModelsByBrandId(brandId: event.brandId);
        print("done3${response}");
        emit(GetCarModelByBrandIdSuccess(carModels: response));
        if (response.isNotEmpty) {}
      } catch (e) {
        emit(GetCarBrandsError(error: e.toString()));
      }
    });
  }
}
