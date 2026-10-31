import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_sheet.dart';
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

/// The wash steps: on the way, arrived, start washing. The next step holds the
/// screen's primary button.
class EventsStepper extends StatelessWidget {
  final OrderModel order;
  final int orderIndex;
  const EventsStepper({
    super.key,
    required this.order,
    required this.orderIndex,
  });

  String _stepName(BuildContext context, int index) => tr(
    context,
    switch (index) {
      0 => AppStrings.onTheWayClient,
      1 => AppStrings.arriveToClient,
      _ => AppStrings.startWashing,
    },
  );

  void _showImagePickerDialog(BuildContext context) {
    showKSheet<void>(
      context: context,
      builder: (BuildContext context) => PhotoSourceSheet(
        title: tr(context, AppStrings.chooseBeforeWashPicture),
        onGallery: () async {
          Navigator.of(context).pop();
          final XFile? image = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            maxHeight: 800,
            maxWidth: 800,
            imageQuality: 100,
          );

          if (image != null && context.mounted) {
            sl<HomeBloc>().add(
              BikerOnWashingOrder(
                orderId: order.sId!,
                orderIndex: orderIndex,
                context: context,
                beforeWashImagePath: image.path,
              ),
            );
          }
        },
        onCamera: () async {
          Navigator.of(context).pop();
          final XFile? image = await ImagePicker().pickImage(
            source: ImageSource.camera,
            maxHeight: 800,
            maxWidth: 800,
            imageQuality: 80,
          );

          if (image != null && context.mounted) {
            sl<HomeBloc>().add(
              BikerOnWashingOrder(
                orderId: order.sId!,
                orderIndex: orderIndex,
                context: context,
                beforeWashImagePath: image.path,
              ),
            );
          }
        },
      ),
    );
  }

  void _onStepTap(BuildContext context, int index) {
    final int step = sl<HomeBloc>().orderStep;
    if (index == 0 && step < 0) {
      sl<HomeBloc>().add(
        BikerOnTheWayOrder(
          orderId: order.sId!,
          orderIndex: orderIndex,
          context: context,
        ),
      );
    } else if (index == 1 && step < 1) {
      sl<HomeBloc>().add(
        BikerArrivedOrder(
          orderId: order.sId!,
          orderIndex: orderIndex,
          context: context,
        ),
      );
    } else if (index == 2 && step < 2) {
      _showImagePickerDialog(context);
    }
  }

  bool _stepLoading(HomeState state, int index, int step) =>
      (state is BikerOnTheWayOrderLoading && index == 0 && step == -1) ||
      (state is BikerArrivedOrderLoading && index == 1 && step == 0) ||
      (state is BikerOnWashingOrderLoading && index == 2 && step == 1);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: sl<HomeBloc>(),
      buildWhen: (HomeState previous, HomeState current) =>
          affectsOrderSteps(current),
      builder: (BuildContext context, HomeState state) {
        final KColors c = KColors.of(context);
        final int step = sl<HomeBloc>().orderStep;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int index = 0; index < 3; index++) ...<Widget>[
              if (index > 0) Divider(height: KSpace.xl, color: c.separator),
              Row(
                children: <Widget>[
                  _StepMark(done: step >= index),
                  const SizedBox(width: KSpace.m),
                  Expanded(
                    child: Text(
                      _stepName(context, index),
                      style: KType.subhead.copyWith(color: c.text),
                    ),
                  ),
                  const SizedBox(width: KSpace.s),
                  if (step < index)
                    KButton(
                      label: tr(context, AppStrings.done),
                      expand: false,
                      variant: index == step + 1
                          ? KButtonVariant.primary
                          : KButtonVariant.secondary,
                      loading: _stepLoading(state, index, step),
                      onPressed: () => _onStepTap(context, index),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StepMark extends StatelessWidget {
  const _StepMark({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? c.success : c.fill,
      ),
      child: SizedBox.square(
        dimension: KSpace.xxl,
        child: done
            ? Icon(Icons.check, size: KSpace.l, color: c.surface)
            : null,
      ),
    );
  }
}
