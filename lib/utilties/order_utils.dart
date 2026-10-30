import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/data/models/apply_promo_code_model.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';

/// Clears all order details including cart, promo codes, and singleton data
void clearAllOrderDetails() {
  // Clear cart and booking order bloc state
  sl<BookingOrderBloc>().add(ClearCartOrder());

  // Clear promo code and reset totalPayModel
  final promoBloc = sl<PromoBloc>();
  promoBloc.add(ClearPromoCodeDetail());
  promoBloc.totalPayModel =
      TotalPayModel(); // Reset totalPayModel to clear old totalPay

  // Clear GeneralSingleton order-related fields
  final generalSingleton = GeneralSingleton();
  generalSingleton.orderId = null;
  generalSingleton.totalPay = null;
  generalSingleton.orderTime = null;
  generalSingleton.nearByDescription = null;
  generalSingleton.isCarFreshened = false;
  generalSingleton.appliedPoints = 0;

  // Clear booking order bloc additional state
  final bookingOrderBloc = sl<BookingOrderBloc>();
  bookingOrderBloc.paymentType = 0;
  bookingOrderBloc.isSubscribed = false;

  // Clear global order ID variable if it exists
  // Note: orderIdd is a global variable in order_detalis_screen.dart
  // We can't clear it from here, but it will be cleared when the screen is disposed
}
