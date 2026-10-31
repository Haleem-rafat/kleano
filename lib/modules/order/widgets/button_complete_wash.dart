import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_sheet.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/event_stepper.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/order/widgets/photo_source_sheet.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

/// Completes the wash once it is under way; asks for the "after" photo first.
class ButtonCompleteWashWidget extends StatelessWidget {
  final String orderId;
  final int index;
  const ButtonCompleteWashWidget({
    super.key,
    required this.orderId,
    required this.index,
  });

  void _showImageSelectionSheet(BuildContext context) {
    showKSheet<void>(
      context: context,
      builder: (BuildContext context) => PhotoSourceSheet(
        title: tr(context, AppStrings.chooseAfterWashPicture),
        onGallery: () async {
          Navigator.of(context).pop();
          final XFile? image = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            maxHeight: 800,
            maxWidth: 800,
            imageQuality: 80,
          );

          if (image != null && context.mounted) {
            sl<HomeBloc>().add(
              BikerCompleteOrder(
                orderId: orderId,
                orderIndex: index,
                context: context,
                afterWashImagePath: image.path,
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
            imageQuality: 100,
          );

          if (image != null && context.mounted) {
            sl<HomeBloc>().add(
              BikerCompleteOrder(
                orderId: orderId,
                orderIndex: index,
                context: context,
                afterWashImagePath: image.path,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: sl<HomeBloc>(),
      buildWhen: (HomeState previous, HomeState current) =>
          affectsOrderSteps(current),
      builder: (BuildContext context, HomeState state) {
        final String? status = sl<HomeBloc>().orderDetails.status;
        final bool canComplete = status == 'ON_WASHING';
        return KButton(
          label: tr(
            context,
            status == 'COMPLETED'
                ? AppStrings.washCompleted
                : AppStrings.completeWash,
          ),
          // The steps above hold the screen's primary until the wash is under way.
          variant: canComplete
              ? KButtonVariant.primary
              : KButtonVariant.secondary,
          loading: state is BikerCompleteOrderLoading,
          onPressed: canComplete
              ? () => _showImageSelectionSheet(context)
              : null,
        );
      },
    );
  }
}
