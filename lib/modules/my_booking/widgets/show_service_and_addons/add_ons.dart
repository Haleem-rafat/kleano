import 'package:flutter/material.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/data/model/add_ons_model.dart';
import 'package:thewasher/modules/my_booking/widgets/empty_services_and_addons.dart';
import 'package:thewasher/modules/my_booking/widgets/show_service_and_addons/card_add_ons.dart';
import 'package:thewasher/modules/my_booking/widgets/wash_section.dart';

class AddOnsList extends StatelessWidget {
  final List<AddOnsModel> addOns;
  const AddOnsList({super.key, required this.addOns});

  @override
  Widget build(BuildContext context) {
    if (addOns.isEmpty) {
      return const EmptyScreen(
        image: AssetsManager.servicesEmpty,
        text: AppStrings.noAddonsRequested,
      );
    }
    return KCard(
      padding: EdgeInsets.zero,
      child: WashRows(
        rows: <Widget>[
          for (final AddOnsModel addOn in addOns) CardAddOns(addOns: addOn),
        ],
      ),
    );
  }
}
