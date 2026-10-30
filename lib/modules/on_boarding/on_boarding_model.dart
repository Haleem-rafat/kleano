
import 'package:thewhsherbiker/core/resources/assets_manager.dart';

class BoardingModel {
  final String image;
  final String title;
  final String body;
  BoardingModel({
    required this.image,
    required this.body,
    required this.title,
  });

  static List<BoardingModel> listOnBoarding = <BoardingModel>[
    BoardingModel(
      image: ImageAssets.onboardOne,
      title: 'Accept ..',
      body: 'wash order request',
    ),
    BoardingModel(
      image: ImageAssets.onboardTwo,
      title: 'Start ..',
      body: 'making cars shiny & clean',
    ),
    BoardingModel(
      image: ImageAssets.onboardThree,
      title: 'Earn ..',
      body: 'Money on your wash',
    ),
  ];
}
