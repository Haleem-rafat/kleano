import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/profile/widget/profile/card_profile_information.dart';

class TotalWashesContainer extends StatelessWidget {
  final String? totalWashes;
  const TotalWashesContainer({Key? key, this.totalWashes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardProfileInformation(
      title: translate(AppStrings.totalWashes),
      subtitle: totalWashes ?? "",
      iconName: ImageAssets.totalWashesLogo,
    );
  }
}
