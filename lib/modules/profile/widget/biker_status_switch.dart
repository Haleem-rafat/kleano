import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/components/swipe_button.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/utilis/enums.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

class BikerStatusSwitchWidget extends StatefulWidget {
  final bool? isHome;
  const BikerStatusSwitchWidget({
    super.key,
    this.isHome = false,
  });

  @override
  State<BikerStatusSwitchWidget> createState() =>
      _BikerStatusSwitchWidgetState();
}

class _BikerStatusSwitchWidgetState extends State<BikerStatusSwitchWidget> {
  late bool _isSuccess;

  @override
  void initState() {
    super.initState();
    _isSuccess = sl<ProfileBloc>().profile.status == BikerStatus.ONLINE.name;
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnline =
        sl<ProfileBloc>().profile.status == BikerStatus.ONLINE.name;
    final String buttonText = isOnline ? 'Online' : 'Offline';
    final Color backgroundColor = isOnline
        ? widget.isHome == true
            ? ColorManager.secondary
            : ColorManager.primary
        : ColorManager.divider;
    final TextDirection textDirection =
        isOnline ? TextDirection.rtl : TextDirection.ltr;
    return CustomSwipeButton(
      isSuccess: _isSuccess,
      initialText: buttonText,
      initialBackgroundColor: backgroundColor,
      textDirection: textDirection,
      onChange: () {},
      onSwipe: _handleSwipe,
    );
  }

  Future<void> _handleSwipe(ActionSliderController controller) async {
    controller.loading();
    await Future.delayed(Duration(milliseconds: 100));
    if (sl<ProfileBloc>().profile.status == BikerStatus.ONLINE.name) {
      sl<ProfileBloc>()
          .add(BikerUpdateStatus(status: BikerStatus.OFFLINE.name));
    } else {
      sl<ProfileBloc>().add(BikerUpdateStatus(status: BikerStatus.ONLINE.name));
    }
    if (sl<ProfileBloc>().state is BikerProfileSuccess) {
      controller.reset();
    }
    setState(() {
      _isSuccess = !_isSuccess;
    });
  }
}
