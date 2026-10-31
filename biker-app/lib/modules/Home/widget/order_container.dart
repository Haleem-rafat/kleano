import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/Home/widget/user_details_widget.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/order/screens/order_details_screen.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/app_date_formatter.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

/// A new request: when, who and where, with details and accept actions.
class OrderContainer extends StatelessWidget {
  final int index;
  const OrderContainer({super.key, required this.index});

  void _accept(BuildContext context, OrderModel order) {
    if (sl<AuthBloc>().currentPosition != LatLng(0, 0)) {
      sl<HomeBloc>().add(
        BikerAcceptOrder(
          context: context,
          orderId: order.sId!,
          orderIndex: index,
          lat: sl<AuthBloc>().currentPosition.latitude.toString(),
          lng: sl<AuthBloc>().currentPosition.longitude.toString(),
          streetName: sl<AuthBloc>().currentAddress,
          subAdministrativeArea: sl<AuthBloc>().administrativeArea,
          details: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final OrderModel order = sl<HomeBloc>().orderList[index];
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${tr(context, AppStrings.arrivedTime)} ${order.startTime != null ? '${AppDateFormatter.allDate(order.startTime!)} ${AppDateFormatter.dateToStringHHMMA(order.startTime!.toLocal())}' : ''}',
            style: KType.footnote.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: KSpace.m),
          UserDetailsWidget(userData: order),
          if (order.bookingDate != null) ...<Widget>[
            const SizedBox(height: KSpace.s),
            RowInfoWidget(
              title: tr(context, AppStrings.washingDate),
              infoText:
                  '${AppDateFormatter.allDateWithDayName(order.startTime!)} ${AppDateFormatter.dateToStringHHMMA(order.startTime!.toLocal())}',
            ),
          ],
          const SizedBox(height: KSpace.m),
          Row(
            children: <Widget>[
              Expanded(
                child: KButton(
                  label: tr(context, AppStrings.viewDetails),
                  variant: KButtonVariant.secondary,
                  onPressed: () {
                    pushPage(
                      context,
                      OrderDetailsScreen(
                        data: order,
                        complete: false,
                        index: index,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: KSpace.s),
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  bloc: sl<HomeBloc>(),
                  buildWhen: (HomeState previous, HomeState current) =>
                      current is BikerAcceptOrderLoading ||
                      current is BikerAcceptOrderSuccess ||
                      current is BikerAcceptOrderFailed,
                  builder: (BuildContext context, HomeState state) => KButton(
                    label: tr(context, AppStrings.accept),
                    loading:
                        state is BikerAcceptOrderLoading &&
                        index == sl<HomeBloc>().selected,
                    onPressed: () => _accept(context, order),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
