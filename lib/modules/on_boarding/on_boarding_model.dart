import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';

class BoardingModel {
  final String image;

  /// Translation keys.
  final String title;
  final String body;
  BoardingModel({required this.image, required this.body, required this.title});

  static List<BoardingModel> listOnBoarding = <BoardingModel>[
    BoardingModel(
      image: ImageAssets.onboardOne,
      title: AppStrings.onboardTitle1,
      body: AppStrings.onboardBody1,
    ),
    BoardingModel(
      image: ImageAssets.onboardTwo,
      title: AppStrings.onboardTitle2,
      body: AppStrings.onboardBody2,
    ),
    BoardingModel(
      image: ImageAssets.onboardThree,
      title: AppStrings.onboardTitle3,
      body: AppStrings.onboardBody3,
    ),
  ];
}
