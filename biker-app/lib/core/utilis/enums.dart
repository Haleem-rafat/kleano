import 'dart:ui';

import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';

enum BikerStatus { ONLINE, OFFLINE }
enum BikerOrderStatus { PENDING, ACTIVE,COMPLETED }

String carImage(String carType){
  switch(carType) {
    case "Sedan": {
      return ImageAssets.sedanLogo;
    }
    break;

    case "Hatchback": {
      return ImageAssets.hatchbackLogo;
    }
    break;

    case "SUV": {
      return ImageAssets.SUVLogo;
    }
    break;

    case "Van": {
      return ImageAssets.vanLogo;
    }
    break;

    default: {
      return ImageAssets.sportCarLogo;
    }
    break;
  }
}

Color orderStateColor(String orderState){
  switch(orderState) {
    case "ACCEPTED_BY_BIKER": {
      return ColorManager.acceptColor;
    }
    break;

    case "BIKER_ON_THE_WAY": {
      return ColorManager.onTheWayColor;
    }
    break;

    case "BIKER_ARRIVED": {
      return ColorManager.secondary.withValues(alpha: 0.1);
    }
    break;

    case "ON_WASHING": {
      return ColorManager.inProgressColor;
    }
    break;

    default: {
      return ColorManager.endedColor;
    }
    break;
  }
}

String orderStateName(String orderState){
  switch(orderState) {
    case "ACCEPTED_BY_BIKER": {
      return translate(AppStrings.accepted);
    }
    break;

    case "BIKER_ON_THE_WAY": {
      return translate(AppStrings.onTheWay);
    }
    break;

    case "BIKER_ARRIVED": {
      return translate(AppStrings.arrived);
    }
    break;

    case "ON_WASHING": {
      return translate(AppStrings.inProgress);
    }
    break;

    default: {
      return translate(AppStrings.ended);
    }
    break;
  }
}

int orderStateStep(String orderState){
  switch(orderState) {
    case "ACCEPTED_BY_BIKER": {
      return -1;
    }
    break;

    case "BIKER_ON_THE_WAY": {
      return 0;
    }
    break;

    case "BIKER_ARRIVED": {
      return 1;
    }
    break;

    case "ON_WASHING": {
      return 2;
    }
    break;

    default: {
      return 3;
    }
    break;
  }
}