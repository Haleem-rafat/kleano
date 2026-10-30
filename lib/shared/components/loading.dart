import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';

class LoadingWidget extends StatelessWidget {
  final double? radius;
  final bool isLight;

  const LoadingWidget({
    super.key,
    this.radius,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return isLight && Platform.isIOS
        ? const CupertinoTheme(
            data: CupertinoThemeData(brightness: Brightness.dark),
            child: CupertinoActivityIndicator(),
          )
        : Center(
            child: CircularProgressIndicator(
            color: isLight ? ColorManager.white : ColorManager.primary,
          ));
  }
}
