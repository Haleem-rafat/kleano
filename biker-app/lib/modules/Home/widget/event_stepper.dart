import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewhsherbiker/core/design/components/k_sheet.dart';
import 'package:thewhsherbiker/core/design/components/k_stage_bar.dart';
import 'package:thewhsherbiker/core/design/components/k_swipe_action.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/order/widgets/photo_source_sheet.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

/// The states after which the open order's step or status may have changed.
bool affectsOrderSteps(HomeState state) =>
    state is BikerOrderSuccess ||
    state is BikerOnTheWayOrderLoading ||
    state is BikerOnTheWayOrderSuccess ||
    state is BikerOnTheWayOrderFailed ||
    state is BikerArrivedOrderLoading ||
    state is BikerArrivedOrderSuccess ||
    state is BikerArrivedOrderFailed ||
    state is BikerOnWashingOrderLoading ||
    state is BikerOnWashingOrderSuccess ||
    state is BikerOnWashingOrderFailed ||
    state is BikerCompleteOrderLoading ||
    state is BikerCompleteOrderSuccess ||
    state is BikerCompleteOrderFailed;

/// The wash progress: a bar of the four stages, then one swipe for the next
/// step. Stages go in order, and the two washing stages ask for a photo first.
class EventsStepper extends StatelessWidget {
  final OrderModel order;
  final int orderIndex;
  const EventsStepper({
    super.key,
    required this.order,
    required this.orderIndex,
  });

  static const int _lastStep = 3;

  // The sheet is closed before the picker opens, so what follows the pick must
  // use the screen's context: the sheet's is no longer mounted.
  void _askForPhoto(
    BuildContext context, {
    required String title,
    required HomeEvent Function(String path) event,
  }) {
    Future<void> pick(
      BuildContext sheetContext,
      ImageSource source,
      int quality,
    ) async {
      Navigator.of(sheetContext).pop();
      final XFile? image = await ImagePicker().pickImage(
        source: source,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: quality,
      );
      if (image != null && context.mounted) {
        sl<HomeBloc>().add(event(image.path));
      }
    }

    showKSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => PhotoSourceSheet(
        title: title,
        onGallery: () => pick(sheetContext, ImageSource.gallery, 100),
        onCamera: () => pick(sheetContext, ImageSource.camera, 80),
      ),
    );
  }

  void _next(BuildContext context, int step) {
    switch (step) {
      case < 0:
        sl<HomeBloc>().add(
          BikerOnTheWayOrder(
            orderId: order.sId!,
            orderIndex: orderIndex,
            context: context,
          ),
        );
      case 0:
        sl<HomeBloc>().add(
          BikerArrivedOrder(
            orderId: order.sId!,
            orderIndex: orderIndex,
            context: context,
          ),
        );
      case 1:
        _askForPhoto(
          context,
          title: tr(context, AppStrings.chooseBeforeWashPicture),
          event: (String path) => BikerOnWashingOrder(
            orderId: order.sId!,
            orderIndex: orderIndex,
            context: context,
            beforeWashImagePath: path,
          ),
        );
      default:
        _askForPhoto(
          context,
          title: tr(context, AppStrings.chooseAfterWashPicture),
          event: (String path) => BikerCompleteOrder(
            orderId: order.sId!,
            orderIndex: orderIndex,
            context: context,
            afterWashImagePath: path,
          ),
        );
    }
  }

  String _nextLabel(int step) => switch (step) {
    < 0 => AppStrings.onTheWayClient,
    0 => AppStrings.arriveToClient,
    1 => AppStrings.startWashing,
    _ => AppStrings.completeWash,
  };

  bool _loading(HomeState state) =>
      state is BikerOnTheWayOrderLoading ||
      state is BikerArrivedOrderLoading ||
      state is BikerOnWashingOrderLoading ||
      state is BikerCompleteOrderLoading;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: sl<HomeBloc>(),
      buildWhen: (HomeState previous, HomeState current) =>
          affectsOrderSteps(current),
      builder: (BuildContext context, HomeState state) {
        final KColors c = KColors.of(context);
        final int step = sl<HomeBloc>().orderStep;
        final bool done =
            step >= _lastStep ||
            sl<HomeBloc>().orderDetails.status == 'COMPLETED';
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            KStageBar(
              step: done ? _lastStep : step,
              stages: <String>[
                tr(context, AppStrings.onTheWay),
                tr(context, AppStrings.arrived),
                tr(context, AppStrings.washing),
                tr(context, AppStrings.completed),
              ],
            ),
            const SizedBox(height: KSpace.xl),
            if (done)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.check_circle, color: c.success),
                  const SizedBox(width: KSpace.s),
                  Flexible(
                    child: Text(
                      tr(context, AppStrings.washCompleted),
                      style: KType.headline.copyWith(color: c.text),
                    ),
                  ),
                ],
              )
            else
              // Keyed by step so the thumb starts over at each new stage.
              KSwipeAction(
                key: ValueKey<int>(step),
                label: tr(context, _nextLabel(step)),
                loading: _loading(state),
                onConfirmed: () => _next(context, step),
              ),
          ],
        );
      },
    );
  }
}
