import 'package:flutter/material.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/data/model/add_ons_model.dart';
import 'package:thewasher/modules/my_booking/widgets/empty_services_and_addons.dart';
import 'package:thewasher/modules/my_booking/widgets/show_service_and_addons/card_add_ons.dart';

class AddOnsList extends StatelessWidget {
  final List<AddOnsModel> addOns;
  const AddOnsList({
    super.key,
    required this.addOns,
  });

  @override
  Widget build(BuildContext context) {
    return addOns.isNotEmpty
        ? ListView.separated(
            shrinkWrap: true,
            itemCount: addOns.length,
            separatorBuilder: (context, index) {
              return AppPadding.p16.ph;
            },
            itemBuilder: (context, index) {
              return CardAddOns(
                addOns: addOns[index],
              );
            })
        : const EmptyScreen(
            image: AssetsManager.servicesEmpty,
            text: AppStrings.noAddonsRequested,
          );
  }
}
