import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_segmented.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/data/model/add_ons_model.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/modules/my_booking/widgets/show_service_and_addons/add_ons.dart';
import 'package:thewasher/modules/my_booking/widgets/show_service_and_addons/services_expanded.dart';

class TabsServicesAndAddOns extends StatefulWidget {
  final List<AddOnsModel> addOnsModel;
  final List<ServiceModel> services;
  const TabsServicesAndAddOns({
    super.key,
    required this.addOnsModel,
    required this.services,
  });

  @override
  State<TabsServicesAndAddOns> createState() => _TabsServicesAndAddOnsState();
}

class _TabsServicesAndAddOnsState extends State<TabsServicesAndAddOns> {
  int currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        KSegmented<int>(
          segments: <int, String>{
            0: translate(AppStrings.services),
            1: translate(AppStrings.addOns),
          },
          selected: currentTabIndex,
          onChanged: (int index) => setState(() => currentTabIndex = index),
        ),
        const SizedBox(height: KSpace.m),
        if (currentTabIndex == 0)
          ServicesExpanded(services: widget.services)
        else
          AddOnsList(addOns: widget.addOnsModel),
      ],
    );
  }
}
