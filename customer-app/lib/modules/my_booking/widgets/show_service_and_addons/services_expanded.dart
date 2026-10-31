import 'package:flutter/material.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/modules/my_booking/widgets/empty_services_and_addons.dart';
import 'package:thewasher/modules/my_booking/widgets/show_service_and_addons/card_services.dart';

class ServicesExpanded extends StatelessWidget {
  final List<ServiceModel> services;
  const ServicesExpanded({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const EmptyScreen(
        image: AssetsManager.servicesEmpty,
        text: AppStrings.noServicesRequested,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: KSpace.m,
      children: <Widget>[
        for (final ServiceModel service in services)
          CardServices(service: service),
      ],
    );
  }
}
