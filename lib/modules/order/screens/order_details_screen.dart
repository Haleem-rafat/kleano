import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_status_chip.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/car_details_widget.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/Home/widget/user_details_widget.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/order/screens/order_change_status_screen.dart';
import 'package:thewhsherbiker/modules/order/widgets/tabs_service_and_addons.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/app_date_formatter.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel data;
  final bool complete;
  final int? index;
  const OrderDetailsScreen({
    super.key,
    required this.data,
    required this.complete,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    const Widget gap = SizedBox(height: KSpace.l);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        title: Text(
          tr(context, AppStrings.washDetails),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: AdaptiveContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            KSpace.l,
            KSpace.s,
            KSpace.l,
            KSpace.l,
          ),
          children: <Widget>[
            KCard(child: UserDetailsWidget(userData: data)),
            gap,
            if (data.vehicle != null) ...<Widget>[
              CarDetailsWidget(carData: data.vehicle),
              gap,
            ],
            if (data.startTime != null || data.description != null) ...<Widget>[
              KCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (data.startTime != null)
                      RowInfoWidget(
                        title: tr(context, AppStrings.washingDate),
                        infoText:
                            '${AppDateFormatter.allDate(data.startTime!)} ${AppDateFormatter.dateToStringHHMMA(data.startTime!.toLocal())}',
                      ),
                    if (data.description != null)
                      RowInfoWidget(
                        title: tr(context, AppStrings.notes),
                        infoText: '${data.description!} ',
                      ),
                  ],
                ),
              ),
              gap,
            ],
            if (data.isCarFreshened == true) ...<Widget>[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: KStatusChip(
                  label: tr(context, 'Car Freshener'),
                  status: KStatus.success,
                ),
              ),
              gap,
            ],
            if (data.addOns != null && data.washingServices != null)
              TabsServicesAndAddOns(
                addOnsModel: data.addOns!,
                services: data.washingServices!,
              ),
          ],
        ),
      ),
      bottomNavigationBar: complete ? null : _actions(context),
    );
  }

  Widget _actions(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.all(KSpace.l),
      child: Row(
        children: <Widget>[
          Expanded(
            child: BlocConsumer<HomeBloc, HomeState>(
              bloc: sl<HomeBloc>(),
              listener: (BuildContext context, HomeState state) {
                if (state is BikerAcceptOrderSuccess) {
                  if (state.details) {
                    _navigateToOrderDetails(context);
                  }
                }
              },
              buildWhen: (HomeState previous, HomeState current) =>
                  current is BikerAcceptOrderLoading ||
                  current is BikerAcceptOrderSuccess ||
                  current is BikerAcceptOrderFailed,
              builder: (BuildContext context, HomeState state) => KButton(
                label: tr(context, AppStrings.accept),
                loading: state is BikerAcceptOrderLoading,
                onPressed: () => _handleButtonPress(context),
              ),
            ),
          ),
          const SizedBox(width: KSpace.s),
          KButton(
            label: tr(context, AppStrings.back),
            variant: KButtonVariant.text,
            expand: false,
            onPressed: () => pop(context),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderDetails(BuildContext context) {
    Navigator.of(context).pushReplacement(
      createRoute(
        OrderChangeStatus(
          order: sl<HomeBloc>().orderDetails,
          notification: false,
        ),
      ),
    );
  }

  void _handleButtonPress(BuildContext context) {
    final HomeBloc homeBloc = sl<HomeBloc>();
    final AuthBloc authBloc = sl<AuthBloc>();

    final int? orderIndex = index;
    final String? orderId = data.sId;
    final String latitude = authBloc.currentPosition.latitude.toString();
    final String longitude = authBloc.currentPosition.longitude.toString();
    final String streetName = authBloc.currentAddress;
    final String subAdministrativeArea = authBloc.administrativeArea;

    if (orderIndex != null && orderId != null) {
      homeBloc.add(
        BikerAcceptOrder(
          context: context,
          orderIndex: orderIndex,
          orderId: orderId,
          lat: latitude,
          lng: longitude,
          streetName: streetName,
          subAdministrativeArea: subAdministrativeArea,
          details: true,
        ),
      );
    }
  }
}

/// A label and its value on one line.
class RowInfoWidget extends StatelessWidget {
  const RowInfoWidget({super.key, required this.title, required this.infoText});

  final String title;
  final String infoText;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$title :',
            style: KType.footnote.copyWith(color: c.textSecondary),
          ),
          const SizedBox(width: KSpace.s),
          Flexible(
            child: Text(
              infoText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: KType.footnote.copyWith(color: c.text),
            ),
          ),
        ],
      ),
    );
  }
}
