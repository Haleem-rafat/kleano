import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:thewasher/modules/Home/data/model/add_ons_model.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/modules/Home/data/response/add_ons_response.dart';
import 'package:thewasher/modules/Home/data/response/services_response.dart';
import 'package:thewasher/repository/home_repo.dart';

part 'offers_event.dart';
part 'offers_state.dart';

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  List<ServiceModel> servicesList = [];
  List<AddOnsModel> addOnsList = [];
  List<ServiceModel> cartServicesList = [];
  List<AddOnsModel> cartAddOnsList = [];
  List<String> cartServicesListString = [];
  List<String> cartAddOnsListString = [];

  List<ServiceModel> mainServices = [];
  List<ServiceModel> extraServices = [];

  bool emptyServices = true;
  int total = 0;
  int? selectedMainServiceIndex;
  String? cardNumber;
  String? cardExpiry;
  String? cardCvv;
  String? cardHolderName;
  String? expiryMonth;
  String? expiryYear;
  bool get hasMainService => cartServicesList
      .any((service) => mainServices.any((main) => main.sId == service.sId));

  OffersBloc() : super(OffersInitial()) {
    // on<GetServices>((GetServices event, Emitter<OffersState> emit) async {
    //   try {
    //     debugPrint("get User Services ...");
    //     emit(GetServicesLoading());
    //     final ServicesResponse response = await HomeRepo.getServices(
    //       event.lat,
    //       event.lng,
    //       event.country,
    //       event.type,
    //     );
    //     if (response.success) {
    //       if (response.message.isEmpty) {
    //         servicesList = response.results!;
    //         // cartServicesList.clear();
    //         // cartServicesListString.clear();
    //         // total = 0;
    //         // emptyServices = false;
    //         // if (event.type == "main") {
    //         //   mainServicesList = servicesList;

    //         //   emit(GetServicesSuccess(servicesList: mainServicesList));
    //         // } else {
    //         //   servicesList = servicesList;
    //         //   emit(GetServicesSuccess(servicesList: servicesList));
    //         // }
    //         mainServicesList = servicesList;
    //         cartServicesList.clear();
    //         cartServicesListString.clear();
    //         total = 0;
    //         emptyServices = false;
    //         emit(GetServicesSuccess(servicesList: servicesList));
    //       } else {
    //         emptyServices = true;
    //         emit(EmptyServices());
    //       }
    //     } else {
    //       emit(GetServicesFailed(error: response.error!.first.message));
    //     }
    //   } catch (e) {
    //     emit(GetServicesFailed(error: e.toString()));
    //   }
    // });
    on<GetServices>((GetServices event, Emitter<OffersState> emit) async {
      emptyServices = true;
      emit(GetServicesLoading());

      try {
        debugPrint("get User Services ...");
        final ServicesResponse response = await HomeRepo.getServices(
          event.lat,
          event.lng,
          event.country,
          event.type,
        );
        if (response.success) {
          if (response.message.isEmpty) {
            servicesList = response.results!;
            mainServices = servicesList
                .where((service) => service.type == "main")
                .toList();
            extraServices = servicesList
                .where((service) => service.type == "extra")
                .toList();
            cartServicesList.clear();
            cartServicesListString.clear();
            total = 0;
            emptyServices = false;
            emit(GetServicesSuccess(
                servicesList: servicesList,
                mainServices: mainServices,
                extraServices: extraServices));
          } else {
            emptyServices = true;
            emit(EmptyServices());
          }
        } else {
          emit(GetServicesFailed(error: response.error!.first.message));
        }
      } catch (e) {
        emit(GetServicesFailed(error: e.toString()));
      }
    });
    on<GetAddOns>((GetAddOns event, Emitter<OffersState> emit) async {
      try {
        debugPrint("get User Add Ons ...");
        emit(GetAddOnsLoading());
        final AddOnsResponse response = await HomeRepo.getAddOns(
          event.lat,
          event.lng,
          event.country,
        );
        if (response.success) {
          addOnsList = <AddOnsModel>[];
          addOnsList = response.results!;
          cartAddOnsList.clear();
          cartAddOnsListString.clear();
          total = 0;
          emit(GetAddOnsSuccess(addOnsList: addOnsList));
        } else {
          emit(GetAddOnsFailed(error: response.error!.first.message));
        }
      } catch (e) {
        emit(GetAddOnsFailed(error: e.toString()));
      }
    });

    on<AddServiceCart>((AddServiceCart event, Emitter<OffersState> emit) async {
      try {
        emit(AddServiceCartLoading());
        if (event.selectedMainServiceIndex != null) {
          // Remove only main services from cart, preserve extra services
          cartServicesList.removeWhere((service) => mainServices
              .any((mainService) => mainService.sId == service.sId));
          cartServicesListString.removeWhere((serviceId) =>
              mainServices.any((mainService) => mainService.sId == serviceId));

          // Recalculate total without main services
          int extraServicesTotal =
              cartServicesList.fold(0, (sum, service) => sum + service.price!);
          int addOnsTotal =
              cartAddOnsList.fold(0, (sum, addon) => sum + addon.price!);
          total = extraServicesTotal + addOnsTotal;
        }
        cartServicesList.add(event.service);
        cartServicesListString.add(event.service.sId!);
        if (event.selectedMainServiceIndex == null) {
          total = total + event.service.price!;
        } else {
          int addOnsTotal =
              cartAddOnsList.fold(0, (sum, addon) => sum + addon.price!);

          total = event.service.price! + addOnsTotal;
        }
        selectedMainServiceIndex = event.selectedMainServiceIndex;

        emit(AddServiceCartSuccess());
      } catch (e) {
        emit(AddServiceCartFailed(error: e.toString()));
      }
    });
    on<AddExtraCart>((AddExtraCart event, Emitter<OffersState> emit) async {
      try {
        debugPrint("Add Extra to  Cart ...");
        emit(AddExtraCartLoading());
        cartAddOnsList.add(event.extra);
        cartAddOnsListString.add(event.extra.sId!);
        total = total + event.extra.price!;
        emit(AddExtraCartSuccess());
      } catch (e) {
        emit(AddExtraCartFailed(error: e.toString()));
      }
    });

    on<DeleteServiceCart>(
        (DeleteServiceCart event, Emitter<OffersState> emit) async {
      try {
        debugPrint("Delete Service from Cart ...");
        emit(DeleteServiceCartLoading());
        cartServicesList.removeAt(event.index);
        cartServicesListString.removeAt(event.index);
        total = total - event.service.price!;
        emit(DeleteServiceCartSuccess());
      } catch (e) {
        emit(DeleteServiceCartFailed(error: e.toString()));
      }
    });

    on<DeleteExtraCart>(
        (DeleteExtraCart event, Emitter<OffersState> emit) async {
      try {
        debugPrint("Delete Extra from Cart ...");
        emit(DeleteExtraCartLoading());
        cartAddOnsList.removeAt(event.index);
        cartAddOnsListString.removeAt(event.index);
        total = total - event.extra.price!;
        emit(DeleteExtraCartSuccess());
      } catch (e) {
        emit(DeleteExtraCartFailed(error: e.toString()));
      }
    });

    on<ClearCart>((ClearCart event, Emitter<OffersState> emit) async {
      try {
        debugPrint("Clere Cart ...");
        emit(ClearCartLoading());
        cartServicesList.clear();
        cartAddOnsList.clear();
        cartServicesListString.clear();
        cartAddOnsListString.clear();
        total = 0;
        emit(ClearCartSuccess());
      } catch (e) {
        emit(ClearCartFailed(error: e.toString()));
      }
    });

    on<ClearAllSelectedServices>(
        (ClearAllSelectedServices event, Emitter<OffersState> emit) async {
      try {
        debugPrint("Clear All Selected Services ...");
        emit(ClearAllSelectedServicesLoading());
        cartServicesList.clear();
        cartServicesListString.clear();
        selectedMainServiceIndex = null;
        // Recalculate total with only add-ons
        total = cartAddOnsList.fold(0, (sum, addon) => sum + addon.price!);
        emit(ClearAllSelectedServicesSuccess());
      } catch (e) {
        emit(ClearAllSelectedServicesFailed(error: e.toString()));
      }
    });

    on<GetGuestServices>(
        (GetGuestServices event, Emitter<OffersState> emit) async {
      try {
        debugPrint("get Guest Services ...");
        emit(GetGuestServicesLoading());
        final ServicesResponse response = await HomeRepo.getGuestServices(
          event.lat,
          event.lng,
          event.country,
        );
        if (response.success) {
          if (response.message.isEmpty) {
            servicesList = response.results ?? <ServiceModel>[];
            mainServices = servicesList
                .where((service) => service.type == "main")
                .toList();
            extraServices = servicesList
                .where((service) => service.type == "extra")
                .toList();
            cartServicesList.clear();
            cartServicesListString.clear();
            total = 0;
            emptyServices = servicesList.isEmpty;
            emit(GetGuestServicesSuccess(
              servicesList: servicesList,
              mainServices: mainServices,
              extraServices: extraServices,
            ));
          } else {
            emit(EmptyGuestServices());
          }
        } else {
          emit(GetGuestServicesFailed(error: response.error!.first.message));
        }
      } catch (e) {
        emit(GetGuestServicesFailed(error: e.toString()));
      }
    });

    on<GetGuestAddOns>((GetGuestAddOns event, Emitter<OffersState> emit) async {
      try {
        debugPrint("get Guest Add Ons ...");
        emit(GetGuestAddOnsLoading());
        final AddOnsResponse response = await HomeRepo.getGuestAddOns(
          event.lat,
          event.lng,
          event.country,
        );
        if (response.success) {
          addOnsList = <AddOnsModel>[];
          addOnsList = response.results!;
          cartAddOnsList.clear();
          cartAddOnsListString.clear();
          emit(GetGuestAddOnsSuccess(addOnsList: addOnsList));
        } else {
          emit(GetGuestAddOnsFailed(error: response.error!.first.message));
        }
      } catch (e) {
        emit(GetGuestAddOnsFailed(error: e.toString()));
      }
    });
  }
}
