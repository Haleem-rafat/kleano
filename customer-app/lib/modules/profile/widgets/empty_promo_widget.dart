import 'package:flutter/material.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/my_booking/widgets/empty_services_and_addons.dart';

class EmptyPromoWidget extends StatelessWidget {
  const EmptyPromoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: EmptyScreen(
        image: AssetsManager.emptyPromo,
        text: AppStrings.noPromoCodesYet,
      ),
    );
  }
}
