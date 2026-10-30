import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class LoadingWidget extends StatelessWidget {
  final double? radius;
  // final bool isLight;

  const LoadingWidget({
    super.key,
    this.radius,
    // this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? const Center(
            child: CupertinoTheme(
              data: CupertinoThemeData(brightness: Brightness.light),
              child: CupertinoActivityIndicator(),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(
            color: ColorManager.primary,
          ));
  }
}
