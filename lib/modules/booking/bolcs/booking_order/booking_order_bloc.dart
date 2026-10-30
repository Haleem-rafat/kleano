import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/booking/data/models/booking_available_model.dart';
import 'package:thewasher/modules/booking/data/models/create_order_request_model.dart';
import 'package:thewasher/modules/booking/data/models/payment_methods_request.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/booking/data/repo/booking_order_repo.dart';
import 'package:thewasher/modules/booking/data/response/calender_avalibale_response.dart';
import 'package:thewasher/modules/booking/data/response/create_order_response.dart';
import 'package:thewasher/modules/booking/data/response/order_by_id_response.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/vehicles_model.dart';
import 'package:thewasher/responses/base_response.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';
part 'booking_order_event.dart';
part 'booking_order_state.dart';

String url = "";

class BookingOrderBloc extends Bloc<BookingOrderEvent, BookingOrderState> {
  int paymentType = 0;
  Location orderLocation = Location();
  bool isSubscribed = false;
  BookingOrderBloc() : super(CreateOrderInitial()) {
    on<CreateOrder>((CreateOrder event, Emitter<BookingOrderState> emit) async {
      try {
        emit(CreateOrderLoading());
        CreateOrderResponse response = await BookingOrderRepo.createOrder(
          request: event.createOrderRequest,
        );
        if (response.success) {
          emit(CreateOrderSuccess(
            reviewOrderModel: response.result!,
            redeemLimit: response.redeemLimit,
          ));
          orderLocation = response.result!.data!.location!;
        } else {
          emit(CreateOrderFailed(errorModel: response.errorModel));
        }
      } on DioException catch (e) {
        if (e.message!.contains('SocketException')) {
          emit(CreateOrderConnectionError());
        } else {
          emit(CreateOrderFailed(error: e.message));
        }
      } catch (e) {
        if (e is SocketException) {
          emit(CreateOrderConnectionError());
        } else {
          emit(CreateOrderFailed(error: e.toString()));
        }
      }
    });

    on<ClearCartOrder>(
        (ClearCartOrder event, Emitter<BookingOrderState> emit) async {
      try {
        emit(ClearCartOrderLoading());
        sl.call<OffersBloc>.call().cartServicesList.clear();
        sl.call<OffersBloc>.call().cartAddOnsList.clear();
        sl.call<OffersBloc>.call().cartServicesListString.clear();
        sl.call<OffersBloc>.call().cartAddOnsListString.clear();
        sl.call<OffersBloc>.call().total = 0;
        sl.call<VehiclesBloc>.call().selectedVehicle = VehiclesModel();
        GeneralSingleton().nearByDescription = '';
        isSubscribed = false;
        GeneralSingleton().orderTime = null;
        paymentType = 0;
        emit(ClearCartOrderSuccess());
        OffersBloc();
      } catch (e) {
        emit(ClearCartOrderFailed(error: e.toString()));
      }
    });

    on<CancelOrder>((CancelOrder event, Emitter<BookingOrderState> emit) async {
      try {
        emit(CancelOrderLoading());
        BaseResponseWithoutResponse response =
            await BookingOrderRepo.userCancelOrder(
          orderId: event.orderId,
        );
        if (response.success) {
          emit(CancelOrderSuccess());
        } else {
          emit(CancelOrderFailed(errormodel: response.errorModel));
        }
      } on DioException catch (e) {
        if (e.message!.contains('SocketException')) {
          emit(CreateOrderConnectionError());
        } else {
          emit(CancelOrderFailed(error: e.message));
        }
      } catch (e) {
        if (e is SocketException) {
          emit(CreateOrderConnectionError());
        } else {
          emit(CancelOrderFailed(error: e.toString()));
        }
      }
    });
    on<PlaceOrder>((PlaceOrder event, Emitter<BookingOrderState> emit) async {
      try {
        emit(PlaceOrderLoading());
        debugPrint("place order ...");

        BaseResponseWithoutResponse response =
            await BookingOrderRepo.userPayOrder(
          applePayId: event.applePayId,
          orderId: event.orderId,
          paymentDetailsRequest: event.paymentDetailsRequest,
        );
        if (response.success) {
          emit(PlaceOrderSuccess(paymentUrl: response.result));

          emit(CreateOrderInitial());
        } else {
          emit(PlaceOrderFailed(errormodel: response.errorModel));
        }
      } on DioException catch (e) {
        if (e.message!.contains('SocketException')) {
          emit(CreateOrderConnectionError());
        } else {
          emit(PlaceOrderFailed(error: e.message));
        }
      } catch (e) {
        if (e is SocketException) {
          emit(CreateOrderConnectionError());
        } else {
          emit(PlaceOrderFailed(error: e.toString()));
        }
      }
    });

    on<GetOrderById>(
        (GetOrderById event, Emitter<BookingOrderState> emit) async {
      try {
        if (event.refresh!) {
          emit(OrderByIdLoading());
        }
        OrderResponse response =
            await BookingOrderRepo.userViewOrderById(orderId: event.orderId);
        if (response.success) {
          emit(OrderByIdSuccess(orderModel: response.result!));
        } else {
          emit(OrderByIdFailed(error: response.message));
        }
      } on DioException catch (e) {
        emit(OrderByIdFailed(error: e.message));
      }
    });

    on<RateOrder>((RateOrder event, Emitter<BookingOrderState> emit) async {
      try {
        emit(RateOrderLoading());
        BaseResponse response = await BookingOrderRepo.rateOrder(
          orderId: event.orderId,
          starsNum: event.starsNum,
        );
        if (response.success) {
          emit(RateOrderSuccess());
        } else {
          emit(RateOrderFailed(
            error: response.message,
            errorModel: response.errorModel,
          ));
        }
      } on DioException catch (e) {
        emit(OrderByIdFailed(error: e.message));
      }
    });

    on<GetCalenderAvalible>(
        (GetCalenderAvalible event, Emitter<BookingOrderState> emit) async {
      try {
        emit(CalenderAvailableLoading());

        // Get city and area from parameters or LocationBloc
        final String cityParam = event.city ?? cityId;
        final String areaParam = event.area ?? areaId;

        // Validate that city and area are available
        if (cityParam.isEmpty || areaParam.isEmpty) {
          debugPrint(
              'Warning: cityId or areaId is empty. cityId: $cityParam, areaId: $areaParam');
          // Emit empty result if location data is not available
          emit(CalenderAvailableSuccess(calenderAvailableModel: []));
          return;
        }

        // Get the specific date to fetch (single day)
        final DateTime now = DateTime.now();
        final DateTime targetDate =
            event.date != null ? DateTime.parse(event.date!) : now;

        String dayParam = _getDayName(targetDate);
        String dateParam = targetDate.toIso8601String().split('T')[0];

        try {
          // Fetch time slots from API for this specific date
          List<CalenderAvalibleResponse> response =
              await BookingOrderRepo.getBookingCalenderAvalabile(
            city: cityParam,
            area: areaParam,
            day: dayParam,
            date: dateParam,
          );

          // Transform API response to CalenderAvailableModel format
          List<CalenderAvailableModel> dayModels =
              _transformToCalenderModels(response, dateParam);

          emit(CalenderAvailableSuccess(calenderAvailableModel: dayModels));
        } catch (e) {
          // If fetching for the day fails, emit empty model
          debugPrint('Error fetching time slots for $dateParam: $e');
          emit(CalenderAvailableSuccess(calenderAvailableModel: [
            CalenderAvailableModel(
              date: targetDate,
              timeSlots: [],
              isActive: false,
            )
          ]));
        }
      } on DioException catch (e) {
        emit(CalenderAvailableFailed(error: e.message));
      } catch (e) {
        emit(CalenderAvailableFailed(error: e.toString()));
      }
    });

    on<ClearSelectedTimeSlot>((event, emit) {
      GeneralSingleton().orderTime = null;
      // Optionally, emit a state if you want to notify listeners
    });
  }

  /// Helper method to get day name from DateTime
  String _getDayName(DateTime date) {
    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY'
    ];
    return days[date.weekday - 1];
  }

  /// Transform API response to CalenderAvailableModel format
  List<CalenderAvailableModel> _transformToCalenderModels(
      List<CalenderAvalibleResponse> responses, String dateStr) {
    if (responses.isEmpty) return [];

    // Parse the date string
    DateTime baseDate = DateTime.parse(dateStr);

    // Group time slots by date (in this case, all for the same date)
    Map<DateTime, List<TimeSlot>> groupedSlots = {};

    for (var response in responses) {
      try {
        // Parse the time slot string (format: "HH:mm")
        List<String> timeParts = response.timeSlot.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        // Create DateTime with the parsed time
        DateTime slotDateTime = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          hour,
          minute,
        );

        // Get the date key (date without time)
        DateTime dateKey = DateTime(
          slotDateTime.year,
          slotDateTime.month,
          slotDateTime.day,
        );

        // Initialize list if not exists
        if (!groupedSlots.containsKey(dateKey)) {
          groupedSlots[dateKey] = [];
        }

        // Add time slot
        groupedSlots[dateKey]!.add(TimeSlot(
          availableTime: slotDateTime,
          isActive: response.isAvailable,
          availableBikersCount: response.availableBikersCount ?? 0,
        ));
      } catch (e) {
        debugPrint('Error parsing time slot: ${response.timeSlot}, error: $e');
      }
    }

    // Create CalenderAvailableModel for each date
    List<CalenderAvailableModel> calenderModels = [];
    groupedSlots.forEach((date, slots) {
      // Sort time slots by time
      slots.sort((a, b) => a.availableTime.compareTo(b.availableTime));

      calenderModels.add(CalenderAvailableModel(
        date: date,
        timeSlots: slots,
        isActive: slots.isNotEmpty,
      ));
    });

    // Sort by date
    calenderModels.sort((a, b) => a.date.compareTo(b.date));

    // If no models created, create one for the base date with empty slots
    if (calenderModels.isEmpty) {
      calenderModels.add(CalenderAvailableModel(
        date: baseDate,
        timeSlots: [],
        isActive: false,
      ));
    }

    return calenderModels;
  }

  /// Clears all cart and order-related state
}
