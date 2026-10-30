import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/widget/profile/card_profile_information.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

class RatingContainer extends StatelessWidget {
  const RatingContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return CardProfileInformation(
      title: translate(AppStrings.rating),
      subtitle: sl<ProfileBloc>().profile.rating != null ? sl<ProfileBloc>().profile.rating!.toDouble().toString() : "0.0",
      iconName: ImageAssets.ratingLogo,
      showRating: true,
    );
  }
}
