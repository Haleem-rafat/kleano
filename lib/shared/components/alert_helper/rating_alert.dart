import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/delayed_methods.dart';
import 'package:thewasher/shared/components/rating_bar.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

class RatingOrderAlert extends StatefulWidget {
  final String? orderId;
  const RatingOrderAlert({super.key, required this.orderId});

  @override
  State<RatingOrderAlert> createState() => _RatingOrderAlertState();
}

class _RatingOrderAlertState extends State<RatingOrderAlert> {
  final GeneralSingleton generalSingleton = GeneralSingleton();
  double ratingCount = 0.0;

  @override
  Widget build(BuildContext context) {
    return KDialog(
      // KDialog has no content slot, so the stars use the icon slot.
      icon: RatingBarShared(
        ratingCount: 0.0,
        itemSize: 32,
        onRatingUpdate: (double rating) => ratingCount = rating,
      ),
      title: translate(AppStrings.howWasYourExperience),
      message: translate(
        AppStrings.pleaseLeaveYourReviewWeAppreciateYourFeedback,
      ),
      actions: <Widget>[
        BlocConsumer<BookingOrderBloc, BookingOrderState>(
          listener: (BuildContext context, BookingOrderState state) {
            if (state is RateOrderFailed) {
              showSnackBar(
                buildContext: context,
                message: state.error != null
                    ? state.error!
                    : Localizations.localeOf(context).languageCode == 'en'
                    ? state.errorModel!.en!
                    : state.errorModel!.ar!,
              );
            } else if (state is RateOrderSuccess) {
              AlertHelper.feedbackSuccess(context);
              if (generalSingleton.openTracking) {
                delayedExecution(
                  context,
                  const Duration(milliseconds: 800),
                  () => popALlAndPushPage(
                    context,
                    MainNavigationScreen(selectedIndex: 0),
                  ),
                );
              } else {
                sl<BookingOrderBloc>().add(
                  GetOrderById(orderId: widget.orderId!),
                );
                delayedExecution(
                  context,
                  const Duration(milliseconds: 800),
                  () => popScreen(context, 2),
                );
              }
            }
          },
          builder: (BuildContext context, BookingOrderState state) {
            return KButton(
              label: translate(AppStrings.submitFeedback),
              loading: state is RateOrderLoading,
              onPressed: () {
                if (ratingCount != 0.0) {
                  sl<BookingOrderBloc>().add(
                    RateOrder(orderId: widget.orderId!, starsNum: ratingCount),
                  );
                }
              },
            );
          },
        ),
        KButton(
          label: translate(AppStrings.skipForNow),
          variant: KButtonVariant.text,
          onPressed: () => pop(context),
        ),
      ],
    );
  }
}
