import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart'
    as order;

/// Request number, customer and street of an order.
class UserDetailsWidget extends StatelessWidget {
  final order.OrderModel userData;

  const UserDetailsWidget({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final String? id = userData.sId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                tr(context, AppStrings.requestID),
                style: KType.headline.copyWith(color: c.text),
              ),
            ),
            Text(
              '# ${(id != null && id.length > 6) ? id.substring(id.length - 6) : id ?? 'N/A'}',
              textDirection: TextDirection.ltr,
              style: KType.headline.copyWith(color: c.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: KSpace.m),
        OrderCustomerRow(order: userData),
        if (userData.location?.streetName != null) ...<Widget>[
          const SizedBox(height: KSpace.xs),
          OrderLocationRow(order: userData),
        ],
      ],
    );
  }
}
