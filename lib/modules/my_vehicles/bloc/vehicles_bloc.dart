import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:thewasher/modules/my_vehicles/data/model/vehicles_model.dart';
import 'package:thewasher/modules/my_vehicles/data/response/vehicles_response.dart';
import 'package:thewasher/repository/vehicles_repo.dart';
import 'package:thewasher/responses/base_response.dart';

part 'vehicles_event.dart';
part 'vehicles_state.dart';

class VehiclesBloc extends Bloc<VehiclesEvent, VehiclesState> {
  List<VehiclesModel> vehiclesList = <VehiclesModel>[];
  VehiclesModel selectedVehicle = VehiclesModel();
  bool getSuccess = false;
  VehiclesBloc() : super(VehiclesInitial()) {
    on<GetVehicles>((GetVehicles event, Emitter<VehiclesState> emit) async {
      try {
        print("Get All Vehicles");
        emit(GetVehiclesLoading());
        final VehiclesResponse? response = await VehiclesRepo.getVehicles();
        if (response!.success) {
          vehiclesList = <VehiclesModel>[];
          vehiclesList = response.results!;
          getSuccess = true;
          if (vehiclesList.isEmpty) {
            emit(GetVehiclesEmpty());
          } else {
            emit(GetVehiclesSuccess(vehiclesList: vehiclesList));
          }
        } else {
          emit(GetVehiclesError(error: response.error!.first.message));
        }
      } catch (e) {
        emit(GetVehiclesError(error: e.toString()));
      }
    });

    on<CreateNewCar>((CreateNewCar event, Emitter<VehiclesState> emit) async {
      try {
        print("Create Car ");
        emit(CreateNewCarLoading());
        final Either<ErrorModel, bool> response =
            await VehiclesRepo.createNewCar(event.brand, event.model,
                event.plateNumber, event.color, event.carImage);
        response.fold(
          (l) => emit(CreateNewCarError(
              error: Localizations.localeOf(event.context).languageCode == 'en'
                  ? l.en
                  : l.ar)),
          (r) => emit(CreateNewCarSuccess()),
        );
      } catch (e) {
        emit(CreateNewCarError(error: e.toString()));
      }
    });

    on<UpdateCar>((UpdateCar event, Emitter<VehiclesState> emit) async {
      try {
        print("Update Car ");
        emit(UpdateCarLoading());
        final Either<ErrorModel, bool> response = await VehiclesRepo.updateCar(
            event.id,
            event.brand,
            event.model,
            event.plateNumber,
            event.color,
            event.carImage);

        response.fold(
          (l) => emit(UpdateCarError(
              error: Localizations.localeOf(event.context).languageCode == 'en'
                  ? l.en
                  : l.ar)),
          (r) => emit(UpdateCarSuccess()),
        );
      } catch (e) {
        emit(UpdateCarError(error: e.toString()));
      }
    });

    on<DeleteCar>((DeleteCar event, Emitter<VehiclesState> emit) async {
      try {
        print("Delete Car ");
        emit(DeleteCarLoading());
        final bool response = await VehiclesRepo.deleteCar(
          event.id,
        );
        if (response) {
          vehiclesList.removeAt(event.index);
          if (vehiclesList.isEmpty) {
            emit(GetVehiclesEmpty());
          } else {
            emit(DeleteCarSuccess());
          }
        } else {
          emit(DeleteCarError(error: "Error"));
        }
      } catch (e) {
        emit(DeleteCarError(error: e.toString()));
      }
    });

    on<SelectCar>((SelectCar event, Emitter<VehiclesState> emit) async {
      try {
        print("Select Car ");
        emit(SelectCarLoading());
        selectedVehicle = event.vehicle;
        emit(SelectCarSuccess());
      } catch (e) {
        emit(DeleteCarError(error: e.toString()));
      }
    });
  }
}
