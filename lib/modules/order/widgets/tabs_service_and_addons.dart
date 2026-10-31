import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/design/components/k_segmented.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/add_ons_widget.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/Home/widget/services_widget.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';

enum _Section { services, addOns }

/// The order's services and add-ons, one at a time.
class TabsServicesAndAddOns extends StatefulWidget {
  final List<AddOns> addOnsModel;
  final List<WashingServices> services;
  const TabsServicesAndAddOns({
    super.key,
    required this.addOnsModel,
    required this.services,
  });

  @override
  State<TabsServicesAndAddOns> createState() => _TabsServicesAndAddOnsState();
}

class _TabsServicesAndAddOnsState extends State<TabsServicesAndAddOns> {
  _Section _section = _Section.services;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        KSegmented<_Section>(
          segments: <_Section, String>{
            _Section.services: tr(context, AppStrings.services),
            _Section.addOns: tr(context, AppStrings.addOns),
          },
          selected: _section,
          onChanged: (_Section value) => setState(() => _section = value),
        ),
        const SizedBox(height: KSpace.l),
        if (_section == _Section.services)
          ServicesWidget(services: widget.services)
        else
          AddOnsWidget(addOns: widget.addOnsModel),
      ],
    );
  }
}
