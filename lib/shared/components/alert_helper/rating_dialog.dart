import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_dialog.dart';
import 'package:thewhsherbiker/core/design/components/k_rating_stars.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/order/bloc/order_bloc.dart';
import 'package:thewhsherbiker/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

/// After a wash: the biker rates the client.
class RatingOrderAlert extends StatefulWidget {
  final String? orderId;
  const RatingOrderAlert({super.key, required this.orderId});

  @override
  State<RatingOrderAlert> createState() => _RatingOrderAlertState();
}

class _RatingOrderAlertState extends State<RatingOrderAlert> {
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return KDialog(
      icon: Icon(Icons.check_rounded, color: c.success),
      title: translate(AppStrings.washCompletedSuccessfully),
      message:
          '${translate(AppStrings.howWasYourClient)} ${translate(AppStrings.leaveReview)}',
      content: KRatingStars(
        value: rating,
        onChanged: (int value) => setState(() => rating = value),
      ),
      actions: <Widget>[
        BlocConsumer<OrderBloc, OrderState>(
          listener: (BuildContext context, OrderState state) {
            if (state is OrderRatingSuccess) {
              pop(context);
              AlertHelper.ratingSuccess(context);
            }
          },
          builder: (BuildContext context, OrderState state) => KButton(
            label: translate(AppStrings.submitFeedback),
            loading: state is OrderRatingLoading,
            onPressed: rating == 0
                ? null
                : () => sl<OrderBloc>().add(
                    BikerRating(
                      starsNum: rating.toDouble(),
                      orderId: widget.orderId!,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
