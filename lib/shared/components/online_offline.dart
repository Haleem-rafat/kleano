import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';

class SwitchSVGs extends StatefulWidget {
  @override
  _SwitchSVGsState createState() => _SwitchSVGsState();
}

class _SwitchSVGsState extends State<SwitchSVGs> with TickerProviderStateMixin {
  bool _value = false;
  late AnimationController _controller;
  late Animation _animation;

  void _startTimer() {
    Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
      setState(() {
        _value = !_value;
      });
    });
  }

  @override
  void initState() {
    _startTimer();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animation = Tween(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    _controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(seconds: 2),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: _value
              ? SvgPicture.asset(ImageAssets.onlineAnimationLogo)
              : SvgPicture.asset(ImageAssets.offlineAnimationLogo),
        ),
        Positioned(
          top: 10.h,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return Container(
                height: 30.h,
                width: 30.w,
                child: Transform.translate(
                  offset: Offset(_animation.value, 0),
                  child: SvgPicture.asset(ImageAssets.tapLogo),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
