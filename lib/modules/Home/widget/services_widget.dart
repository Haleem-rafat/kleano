import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/order/widgets/card_services.dart';

/// The order's services, inside the details screen's scroll view.
class ServicesWidget extends StatelessWidget {
  final List<WashingServices>? services;
  const ServicesWidget({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final WashingServices service in services!)
          Padding(
            padding: const EdgeInsets.only(bottom: KSpace.m),
            child: CardServices(service: service),
          ),
      ],
    );
  }
}
