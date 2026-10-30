import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/order/widgets/card_services.dart';

class ServicesWidget extends StatelessWidget {
  final List<WashingServices>? services;
  const ServicesWidget({Key? key, required this.services}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<WashingServices> servicesList = services ?? <WashingServices>[];
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services!.length,
      separatorBuilder: (BuildContext context, int index) {
        return index == servicesList.length - 1 ? 32.verticalSpace : AppPadding.p16.verticalSpace;
      },
      itemBuilder: (BuildContext context, int index) {
        return CardServices(
          service: servicesList[index],
        );
      },
    );
  }
}
