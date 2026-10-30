import 'package:flutter/material.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/modules/my_booking/widgets/empty_services_and_addons.dart';
import 'package:thewasher/modules/my_booking/widgets/show_service_and_addons/card_services.dart';

class ServicesExpanded extends StatelessWidget {
  final List<ServiceModel> services;
  const ServicesExpanded({
    super.key,
    required this.services,
  });
  @override
  Widget build(BuildContext context) {
    return services.isNotEmpty
        ? ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            separatorBuilder: (context, index) {
              return AppPadding.p16.ph;
            },
            itemBuilder: (context, index) {
              return CardServices(
                service: services[index],
              );
            },
          )
        : const EmptyScreen(
            image: AssetsManager.servicesEmpty,
            text: AppStrings.noServicesRequested,
          );
  }
}
