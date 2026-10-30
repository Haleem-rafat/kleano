import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/shared/singleton.dart';

Tuple4<Color, String ,Color, int> getStepData(String status) {
  final map = {
    AppConstants.acceptedByBiker: Tuple4(
      const Color.fromRGBO(111, 251, 76, 0.1),
      translate(AppStrings.accepted),
      const Color.fromRGBO(28, 127, 84, 1),
      GeneralSingleton().step = -1,
    ),
    AppConstants.bikerOnTheWay: Tuple4(
      const Color.fromRGBO(103, 135, 198, 0.1),
      translate(AppStrings.onTheWay),
      const Color.fromRGBO(225, 111, 0, 1),
      GeneralSingleton().step = 0,
    ),
    AppConstants.bikerArrived: Tuple4(
      const Color.fromRGBO(251, 174, 76, 0.1),
      translate(AppStrings.arrived),
      ColorManager.darkGrey,
      GeneralSingleton().step = 1,
    ),
    AppConstants.onWashing: Tuple4(
      const Color.fromRGBO(255, 228, 54, 0.1),
      translate(AppStrings.inProgress),
      ColorManager.darkGrey,
      GeneralSingleton().step = 2,

    ),
    AppConstants.completed: Tuple4(
      const Color.fromRGBO(245, 240, 250, 1),
      translate(AppStrings.ended),
      ColorManager.divider,
      GeneralSingleton().step = 3,
    ),
  };
  return map[status] ?? Tuple4(
       ColorManager.divider,
      translate(AppStrings.biker),
      ColorManager.divider,
      GeneralSingleton().step = -1,
    );
  // return map.containsKey(status) ? map[status] : Tuple2(ColorManager.divider, translate(AppStrings.biker));
}
