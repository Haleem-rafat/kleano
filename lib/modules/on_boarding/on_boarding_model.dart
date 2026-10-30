import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

class BoardingModel {
  final String image;
  final String title;
  final String body;
  BoardingModel({required this.image, required this.body, required this.title});

  static List<BoardingModel> get listOnBoarding => <BoardingModel>[
    BoardingModel(
      image: AssetsManager.onBoardingOne,
      title: translate(AppStrings.title1),
      body: translate(AppStrings.body1),
    ),
    BoardingModel(
      image: AssetsManager.onBoardingTwo,
      title: translate(AppStrings.title2),
      body: translate(AppStrings.body2),
    ),
    BoardingModel(
      image: AssetsManager.onBoardingThree,
      title: translate(AppStrings.title3),
      body: translate(AppStrings.body3),
    ),
  ];
}
