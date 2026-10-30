import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewhsherbiker/core/network/biker_socket.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/utilis/enums.dart';
import 'package:thewhsherbiker/core/utilis/marker_icon.dart';
import 'package:thewhsherbiker/models/error_model.dart';
import 'package:thewhsherbiker/modules/Home/data/repo/home_repo.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/responses/generic_response.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  List<OrderModel> orderList = <OrderModel>[];
  List<OrderModel> activeList = <OrderModel>[];
  List<OrderModel> completeList = <OrderModel>[];
  OrderModel orderDetails = OrderModel();
  final SocketService socketService = SocketService();
  int pendingPageNumber = 1;
  int pendingTotalPage = 0;
  int pendingTotalLength = 0;

  int activePageNumber = 1;
  int activeTotalPage = 0;
  int activeTotalLength = 0;

  int completePageNumber = 1;
  int completeTotalPage = 0;
  int completeTotalLength = 0;

  int selected = 0;
  bool details = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int dialogCount = 0;
  int orderStep = -1;
  HomeBloc() : super(HomeInitial()) {
    on<BikerGetOrdersPending>(
        (BikerGetOrdersPending event, Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker Get Order");
        emit(BikerGetOrdersLoading());
        pendingPageNumber = 1;
        pendingTotalPage = 0;
        final GenericResponse<OrderModel> response = await HomeRepo.bikerOrders(
            pendingPageNumber, BikerOrderStatus.PENDING.name);
        if (response.success) {
          pendingPageNumber++;
          pendingTotalPage = response.totalPages;
          pendingTotalLength = response.totalItems;
          orderList = <OrderModel>[];
          orderList = response.results!;
          if (orderList.isEmpty) {
            emit(BikerGetOrdersEmpty());
          } else {
            emit(BikerGetOrdersSuccess(
                orderList: orderList, pendingTotalLength: pendingTotalLength));
          }
        } else {
          emit(BikerGetOrdersFailed(error: response.error!.first.message));
        }
      } catch (e) {
        emit(BikerGetOrdersFailed(error: e.toString()));
      }
    });

    on<BikerGetOrdersPendingPagination>(
        (BikerGetOrdersPendingPagination event, Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker Get Order Pagination");
        emit(BikerGetOrdersPaginationLoading());
        if (pendingPageNumber <= pendingTotalPage) {
          final GenericResponse<OrderModel> response =
              await HomeRepo.bikerOrders(
                  pendingPageNumber, BikerOrderStatus.PENDING.name);
          if (response.success) {
            pendingPageNumber++;
            pendingTotalLength = response.totalItems;
            orderList.addAll(response.results!);
            emit(BikerGetOrdersSuccess(
                orderList: orderList, pendingTotalLength: pendingTotalLength));
          } else {
            emit(BikerGetOrdersFailed(error: response.error!.first.message));
          }
        } else {
          emit(BikerGetOrdersSuccess(
              orderList: orderList, pendingTotalLength: pendingTotalLength));
        }
      } catch (e) {
        emit(BikerGetOrdersFailed(error: e.toString()));
      }
    });

    on<BikerGetOrdersAccept>(
        (BikerGetOrdersAccept event, Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker Get Order Accept");
        emit(BikerGetOrdersAcceptLoading());
        activePageNumber = 1;
        activeTotalPage = 0;
        final GenericResponse<OrderModel> response = await HomeRepo.bikerOrders(
            activePageNumber, BikerOrderStatus.ACTIVE.name);
        if (response.success) {
          activePageNumber++;
          activeTotalPage = response.totalPages;
          activeTotalLength = response.totalItems;
          activeList = <OrderModel>[];
          activeList = response.results!;
          if (activeList.isEmpty) {
            emit(BikerGetOrdersAcceptEmpty());
          } else {
            emit(BikerGetOrdersAcceptSuccess());
          }
        } else {
          emit(
              BikerGetOrdersAcceptFailed(error: response.error!.first.message));
        }
      } catch (e) {
        emit(BikerGetOrdersAcceptFailed(error: e.toString()));
      }
    });

    on<BikerGetOrdersAcceptPagination>(
        (BikerGetOrdersAcceptPagination event, Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker Get Order Accept Pagination");
        emit(BikerGetOrdersPaginationAcceptLoading());
        if (activePageNumber <= activeTotalPage) {
          final GenericResponse<OrderModel> response =
              await HomeRepo.bikerOrders(
                  activePageNumber, BikerOrderStatus.ACTIVE.name);
          if (response.success) {
            activePageNumber++;
            activeTotalLength = response.totalItems;
            activeList.addAll(response.results!);
            emit(BikerGetOrdersAcceptSuccess());
          } else {
            emit(BikerGetOrdersAcceptFailed(
                error: response.error!.first.message));
          }
        } else {
          emit(BikerGetOrdersAcceptSuccess());
        }
      } catch (e) {
        emit(BikerGetOrdersAcceptFailed(error: e.toString()));
      }
    });

    on<BikerGetOrdersComplete>(
        (BikerGetOrdersComplete event, Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker Get Order Complete");
        emit(BikerGetOrdersCompleteLoading());
        completePageNumber = 1;
        completeTotalPage = 0;
        final GenericResponse<OrderModel> response = await HomeRepo.bikerOrders(
            completePageNumber, BikerOrderStatus.COMPLETED.name);
        if (response.success) {
          completePageNumber++;
          completeTotalPage = response.totalPages;
          completeTotalLength = response.totalItems;
          completeList = <OrderModel>[];
          completeList = response.results!;
          if (completeList.isEmpty) {
            emit(BikerGetOrdersCompleteEmpty());
          } else {
            emit(BikerGetOrdersCompleteSuccess());
          }
        } else {
          debugPrint("complete Error : ${response.error!.first.message}");
          emit(BikerGetOrdersCompleteFailed(
              error: response.error!.first.message));
        }
      } catch (e) {
        debugPrint("complete Error2 : ${e.toString()}");
        emit(BikerGetOrdersCompleteFailed(error: e.toString()));
      }
    });

    on<BikerGetOrdersCompletePagination>(
        (BikerGetOrdersCompletePagination event,
            Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker Get Order Complete Pagination");
        emit(BikerGetOrdersPaginationCompleteLoading());
        if (completePageNumber <= completeTotalPage) {
          final GenericResponse<OrderModel> response =
              await HomeRepo.bikerOrders(
                  activePageNumber, BikerOrderStatus.COMPLETED.name);
          if (response.success) {
            completePageNumber++;
            completeTotalLength = response.totalItems;
            completeList.addAll(response.results!);
            emit(BikerGetOrdersCompleteSuccess());
          } else {
            emit(BikerGetOrdersCompleteFailed(
                error: response.error!.first.message));
          }
        } else {
          emit(BikerGetOrdersCompleteSuccess());
        }
      } catch (e) {
        emit(BikerGetOrdersCompleteFailed(error: e.toString()));
      }
    });

    on<BikerGetNewOrders>(
        (BikerGetNewOrders event, Emitter<HomeState> emit) async {
      try {
        debugPrint("🚀 Biker Get New Order Start");

        // Use SocketService to connect
        await socketService.connect(
          onNewOrder: (OrderModel order) {
            debugPrint("📦 New order received in HomeBloc");
            _audioPlayer.play(AssetSource('audio/newOrder.wav'));
            add(BikerGetOrdersAccept());
          },
          onError: (String error) {
            debugPrint("❌ Socket error: $error");
            emit(BikerGetNewOrdersFailed(error: error));
          },
        );

        debugPrint("✅ Socket connection setup complete");
      } catch (e) {
        debugPrint("❌ Socket connection failed: $e");
        emit(BikerGetNewOrdersFailed(error: e.toString()));
      }
    });

    on<BikerCloseSocket>(
        (BikerCloseSocket event, Emitter<HomeState> emit) async {
      debugPrint('🔌 Closing socket connection');
      socketService.disconnect();
      emit(SocketClosed());
    });

    on<BikerAcceptOrder>(
        (BikerAcceptOrder event, Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker Accept Order ... ");
        emit(BikerAcceptOrderLoading());
        selected = event.orderIndex;
        final Either<ErrorModel, bool> response =
            await HomeRepo.bikerOrderAccept(
          event.orderId,
          event.lat,
          event.lng,
          event.streetName,
          event.subAdministrativeArea,
        );

        response.fold(
          (ErrorModel l) {
            debugPrint("ooooo ${l.en}");
            emit(BikerAcceptOrderFailed(
                error:
                    Localizations.localeOf(event.context).languageCode == 'en'
                        ? l.en!
                        : l.ar!));
          },
          (bool r) {
            details = event.details;
            orderDetails = orderList[event.orderIndex];
            pendingTotalLength--;
            orderList[event.orderIndex].status = "ACCEPTED_BY_BIKER";
            activeList.insert(0, orderList[event.orderIndex]);
            orderList.removeAt(event.orderIndex);
            emit(BikerAcceptOrderSuccess(
                orderId: event.orderId, details: details));
          },
        );
      } catch (e) {
        debugPrint("kkkk ${e.toString()}");
        emit(BikerAcceptOrderFailed(error: e.toString()));
      }
    });

    on<BikerOnTheWayOrder>(
        (BikerOnTheWayOrder event, Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker on The Way Order ... ");
        emit(BikerOnTheWayOrderLoading());
        final Either<ErrorModel, bool> response =
            await HomeRepo.bikerOnTheWayOrder(event.orderId);

        response.fold(
          (ErrorModel l) => emit(BikerOnTheWayOrderFailed(
              error: Localizations.localeOf(event.context).languageCode == 'en'
                  ? l.en!
                  : l.ar!)),
          (bool r) {
            if (event.orderIndex != -1) {
              activeList[event.orderIndex].status = "BIKER_ON_THE_WAY";
            }
            orderDetails.status = "BIKER_ON_THE_WAY";
            orderStep++;
            emit(BikerOnTheWayOrderSuccess(orderId: event.orderId));
          },
        );
      } catch (e) {
        emit(BikerOnTheWayOrderFailed(error: e.toString()));
      }
    });

    on<BikerArrivedOrder>(
        (BikerArrivedOrder event, Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker Arrived Order ... ");
        emit(BikerArrivedOrderLoading());
        final Either<ErrorModel, bool> response =
            await HomeRepo.bikerArrivedOrder(event.orderId);

        response.fold(
          (ErrorModel l) => emit(BikerArrivedOrderFailed(
              error: Localizations.localeOf(event.context).languageCode == 'en'
                  ? l.en!
                  : l.ar!)),
          (bool r) {
            if (event.orderIndex != -1) {
              activeList[event.orderIndex].status = "BIKER_ARRIVED";
            }
            orderDetails.status = "BIKER_ARRIVED";
            orderStep++;
            emit(BikerArrivedOrderSuccess(orderId: event.orderId));
          },
        );
      } catch (e) {
        emit(BikerArrivedOrderFailed(error: e.toString()));
      }
    });

    on<BikerOnWashingOrder>(
        (BikerOnWashingOrder event, Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker On Washing Order ... ");
        emit(BikerOnWashingOrderLoading());
        final Either<ErrorModel, bool> response =
            await HomeRepo.bikerOnWashingOrder(event.orderId,
                beforeWashImagePath: event.beforeWashImagePath);

        response.fold(
          (ErrorModel l) => emit(BikerOnWashingOrderFailed(
              error: Localizations.localeOf(event.context).languageCode == 'en'
                  ? l.en!
                  : l.ar!)),
          (bool r) {
            if (event.orderIndex != -1) {
              activeList[event.orderIndex].status = "ON_WASHING";
            }
            orderDetails.status = "ON_WASHING";
            orderStep++;
            emit(BikerOnWashingOrderSuccess(orderId: event.orderId));
          },
        );
      } catch (e) {
        emit(BikerOnWashingOrderFailed(error: e.toString()));
      }
    });

    on<BikerCompleteOrder>(
        (BikerCompleteOrder event, Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker Complete Order ... ");
        emit(BikerCompleteOrderLoading());
        final Either<ErrorModel, bool> response =
            await HomeRepo.bikerCompleteOrder(event.orderId,
                afterWashImagePath: event.afterWashImagePath);

        response.fold(
          (ErrorModel l) => emit(BikerCompleteOrderFailed(
              error: Localizations.localeOf(event.context).languageCode == 'en'
                  ? l.en!
                  : l.ar!)),
          (bool r) {
            if (event.orderIndex != -1) {
              activeList.removeAt(event.orderIndex);
            }
            orderDetails.status = "COMPLETED";
            orderStep++;
            emit(BikerCompleteOrderSuccess(orderId: event.orderId));
          },
        );
      } catch (e) {
        emit(BikerCompleteOrderFailed(error: e.toString()));
      }
    });

    on<BikerCancelOrder>(
        (BikerCancelOrder event, Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker Cancel Order ... ");
        emit(BikerCancelOrderLoading(orderId: event.orderId));
        final Either<ErrorModel, bool> response =
            await HomeRepo.bikerCancelOrder(event.orderId);

        response.fold(
          (ErrorModel l) => emit(BikerCancelOrderFailed(
              error: Localizations.localeOf(event.context).languageCode == 'en'
                  ? l.en!
                  : l.ar!)),
          (bool r) {
            if (event.orderIndex >= 0 && event.orderIndex < activeList.length) {
              activeList.removeAt(event.orderIndex);
            } else {
              final int index = activeList
                  .indexWhere((OrderModel o) => o.sId == event.orderId);
              if (index != -1) {
                activeList.removeAt(index);
              }
            }
            if (activeTotalLength > 0) {
              activeTotalLength--;
            }
            if (orderDetails.sId == event.orderId) {
              orderDetails.status = "CANCELED";
            }
            orderStep = 3;
            emit(BikerCancelOrderSuccess(orderId: event.orderId));
          },
        );
      } catch (e) {
        emit(BikerCancelOrderFailed(error: e.toString()));
      }
    });

    on<BikerOrder>((BikerOrder event, Emitter<HomeState> emit) async {
      try {
        debugPrint("Biker Get Order details");
        emit(BikerOrderLoading());
        final GenericResponse<OrderModel> response =
            await HomeRepo.bikerOrder(event.orderId);
        if (response.success) {
          if (!event.context.mounted) return;
          final BitmapDescriptor markerBikerLocation =
              await MarkerIcon.svgAsset(
                  assetName: ImageAssets.userLocationMarker,
                  context: event.context,
                  size: 40.w);
          if (!event.context.mounted) return;
          final BitmapDescriptor markerUserLocation = await MarkerIcon.svgAsset(
              assetName: ImageAssets.currentLocationPin,
              context: event.context,
              size: 40);
          orderDetails = response.result!;
          orderStep = orderStateStep(response.result!.status!);
          emit(BikerOrderSuccess(
              markerBikerLocation: markerBikerLocation,
              markerUserLocation: markerUserLocation));
        } else {
          emit(BikerOrderFailed(error: response.error!.first.message));
        }
      } catch (e) {
        emit(BikerOrderFailed(error: e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    debugPrint('🧹 Disposing HomeBloc resources...');
    // socketService.dispose();
    _audioPlayer.dispose();
    return super.close();
  }
}
