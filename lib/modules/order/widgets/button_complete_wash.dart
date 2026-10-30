import 'package:action_slider/action_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewhsherbiker/core/components/swipe_button.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

class ButtonCompleteWashWidget extends StatefulWidget {
  final String orderId;
  final int index;
  const ButtonCompleteWashWidget({
    super.key,
    required this.orderId,
    required this.index,
  });

  @override
  State<ButtonCompleteWashWidget> createState() =>
      _ButtonCompleteWashWidgetState();
}

class _ButtonCompleteWashWidgetState extends State<ButtonCompleteWashWidget> {
  late bool _isSuccess;

  @override
  void initState() {
    super.initState();
    _isSuccess = sl<HomeBloc>().orderDetails.status == "COMPLETED";
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = sl<HomeBloc>().orderDetails.status == "COMPLETED";
    final String buttonText = isCompleted
        ? translate(AppStrings.washCompleted)
        : translate(AppStrings.completeWash);
    final Color backgroundColor =
        isCompleted ? ColorManager.primary : ColorManager.divider;
    final TextDirection textDirection =
        isCompleted ? TextDirection.rtl : TextDirection.ltr;
    return sl<HomeBloc>().state is BikerCompleteOrderLoading
        ? Center(child: CircularProgressIndicator())
        : CustomSwipeButton(
            height: 50,
            width: 327,
            isSuccess: _isSuccess,
            initialText: buttonText,
            initialBackgroundColor: backgroundColor,
            textDirection: textDirection,
            onChange: () {},
            onSwipe: _handleSwipe,
          );
  }

  Future<void> _handleSwipe(ActionSliderController controller) async {
    print('YYYYYYYY ${sl<HomeBloc>().orderStep}');
    if (sl<HomeBloc>().orderDetails.status == "ON_WASHING") {
      _showImageSelectionSheet(controller);
    } else if (sl<HomeBloc>().state is BikerCompleteOrderSuccess) {
      controller.reset();
      setState(() {
        _isSuccess = !_isSuccess;
      });
    }
  }

  void _showImageSelectionSheet(ActionSliderController controller) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          translate(AppStrings.chooseAfterWashPicture),
          style: AppStyles.title16Bold,
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              final XFile? image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                maxHeight: 800,
                maxWidth: 800,
                imageQuality: 80,
              );

              if (image != null) {
                sl<HomeBloc>().add(BikerCompleteOrder(
                  orderId: widget.orderId,
                  orderIndex: widget.index,
                  context: context,
                  afterWashImagePath: image.path,
                ));
              } else {
                controller.reset();
              }
            },
            child: Text(
              translate(AppStrings.chooseFromGallery),
              style: AppStyles.title16Regular
                  .copyWith(color: ColorManager.primary),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              final XFile? image = await ImagePicker().pickImage(
                source: ImageSource.camera,
                maxHeight: 800,
                maxWidth: 800,
                imageQuality: 100,
              );

              if (image != null) {
                sl<HomeBloc>().add(BikerCompleteOrder(
                  orderId: widget.orderId,
                  orderIndex: widget.index,
                  context: context,
                  afterWashImagePath: image.path,
                ));
              } else {
                controller.reset();
              }
            },
            child: Text(
              translate(AppStrings.takeAPhoto),
              style: AppStyles.title16Regular
                  .copyWith(color: ColorManager.primary),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            controller.reset();
          },
          child: Text(
            translate(AppStrings.cancel),
            style: AppStyles.title16Regular.copyWith(color: ColorManager.red),
          ),
        ),
      ),
    );
  }
}
