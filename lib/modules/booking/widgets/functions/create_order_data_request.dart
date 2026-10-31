import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/data/models/create_order_request_model.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/widgets/button_use_promo.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class CreateOrderFunction {
  BookingOrderBloc orderBloc = sl<BookingOrderBloc>();
  GeneralSingleton singleton = GeneralSingleton();
  final locationBloc = sl<LocationBloc>();
  final offersBloc = sl<OffersBloc>();
  final userProfileBloc = sl<GetUserProfileBloc>();
  final vehiclesBloc = sl<VehiclesBloc>();
  final plansAndSubscriptionBloc = sl<PlansAndSubscriptionBloc>();
  final promoBloc = sl<PromoBloc>();

  late double latitude;
  late double longitude;
  late String? locationName;
  late String? subAdministrativeArea;
  late String? country;
  late String formattedStartTime;
  late String type;
  late String vehicleId;
  late List<String>? washingServices;
  late List<String>? addOns;
  late String? description;
  late String? subscriptionId;
  late double totalPrice;
  late String paymentType;
  late String bookingDate;
  late String? code;
  late bool isCarFreshened;
  late String userOS;
  late String timeSlot;

  void createOrderDataRequest() {
    debugPrint("sadassasdaads ${singleton.orderTime}");

    latitude = blcoPosition.latitude;
    longitude = blcoPosition.longitude;
    locationName = blcoLocationName;
    subAdministrativeArea = blcoSubAdministrativeArea;

    country = blcoCountry;
    formattedStartTime = singleton.orderTime!.toUtc().toIso8601String();
    type = userProfileBloc.profile.isSubscribed == true
        ? AppConstants.subscriptionBooking
        : AppConstants.serviceBooking;
    vehicleId =
        vehiclesBloc.selectedVehicle.sId ??
        (throw Exception('Vehicle ID is missing.'));
    washingServices = offersBloc.cartServicesListString.isNotEmpty
        ? offersBloc.cartServicesListString
        : null;
    addOns = offersBloc.cartAddOnsListString.isNotEmpty
        ? offersBloc.cartAddOnsListString
        : null;
    description = singleton.nearByDescription != ''
        ? singleton.nearByDescription
        : null;
    subscriptionId = userProfileBloc.profile.isSubscribed == true
        ? plansAndSubscriptionBloc.subscription.sId
        : null;
    // Always use the original total price (server will handle discount)
    double finalTotalPrice = offersBloc.total.toDouble();

    totalPrice = finalTotalPrice;

    // Determine payment type based on total price and selected payment method
    if (totalPrice == 0.0) {
      paymentType = AppConstants.subscribed;
    } else {
      switch (orderBloc.paymentType) {
        case AppConstants.paymentTypeCreditCard:
          paymentType = AppConstants.creadit;
          break;
        case AppConstants.paymentTypeWallet:
          paymentType = AppConstants.wallet;
          break;
        case AppConstants.paymentTypeApplePay:
          paymentType = AppConstants.applePay;
          break;
        default:
          // Default to credit card for unknown payment types
          paymentType = AppConstants.creadit;
      }
    }

    bookingDate = singleton.orderTime!.toUtc().toIso8601String();
    debugPrint("dsasddasasdasdsd: $bookingDate");

    // Format time slot as "HH:mm" (e.g., "13:15")
    timeSlot = DateFormat('HH:mm', 'en').format(singleton.orderTime!);
    debugPrint("Time slot formatted: $timeSlot");

    // Only send promo code if user actually applied it successfully
    if (promoBloc.state is GetPromoCodeDetailSuccess &&
        copiedPromoCode != null) {
      code = copiedPromoCode!.promoCode;
    } else {
      code = null; // Don't send promo code if not applied
    }
    debugPrint("dsasadwdqwqw: ${singleton.isCarFreshened}");
    debugPrint("dsasadwdqwqw: ${Platform.isAndroid ? 'ANDROID' : 'IOS'}");
    orderBloc.add(
      CreateOrder(
        createOrderRequest: CreateOrderRequest(
          isCarFreshened: singleton.isCarFreshened,
          userOS: Platform.isAndroid ? 'ANDROID' : 'IOS',
          locationRequest: LocationRequest(
            latitude: latitude,
            longitude: longitude,
            streetName: locationName,
            subAdministrativeArea: subAdministrativeArea,
            country: country,
          ),
          startTime: formattedStartTime,
          type: type,
          vehicleId: vehicleId,
          washingServices: washingServices,
          addOns: addOns,
          description: description,
          subscriptionId: subscriptionId,
          totalPrice: totalPrice,
          paymentType: paymentType,
          bookingDate: bookingDate,
          code: code,
          timeSlot: timeSlot,
          appliedPoints: singleton.appliedPoints,
        ),
      ),
    );
  }
}
