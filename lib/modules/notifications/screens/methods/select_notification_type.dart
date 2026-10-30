import 'package:flutter/cupertino.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/my_booking/screens/wash_details.dart';
import 'package:thewasher/modules/notifications/data/models/notifaction_model.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/pormo_codes_screen.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

selectActionNotificationType(Notifications notification, BuildContext buildContext) {
  switch (notification.type) {
    case AppConstants.promoCodeBased:
      pushPage(
        buildContext,
        PromoCodeScreen(
          highlightPromoId: notification.orderId,
        ),
      );
      break;
    case AppConstants.orderTracking:
      sl<BookingOrderBloc>().add(
        GetOrderById(orderId: notification.orderId!),
      );
      break;
    case AppConstants.orderWaitingForAdmin:
      showSnackBar(
        buildContext: buildContext,
        message: AppStrings.connectingYouToNearestBiker,
      );
      break;
    case AppConstants.completedOrder:
      pushPage(
          buildContext,
          WashDetailsScreen(
            orderId: notification.orderId!,
          ));
      break;
  }
}

String getImageNotificationType(String type) {
  switch (type) {
    case AppConstants.promoCodeBased:
      return AssetsManager.promoCodeIcon;
    case AppConstants.orderTracking:
      return AssetsManager.trackingOrderIcon;
    case AppConstants.completedOrder:
      return AssetsManager.completeOrderIcon;
    default:
      return AssetsManager.waitingBikereIcon;
  }
}
