import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/order/screens/order_details_screen.dart';
import 'package:thewhsherbiker/utilties/app_date_formatter.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

/// A finished order: date, request number, customer and street.
class CompletedCard extends StatelessWidget {
  final OrderModel order;
  const CompletedCard({super.key, required this.order});

  void _openDetails(BuildContext context) {
    pushPage(context, OrderDetailsScreen(data: order, complete: true));
  }

  /// The last six characters of the id, as the rest of the app shows it.
  String get _shortId {
    final String? id = order.sId;
    if (id == null) return 'N/A';
    return id.length > 6 ? id.substring(id.length - 6) : id;
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final DateTime? created = order.createdAt;
    return KCard(
      onTap: () => _openDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  tr(context, AppStrings.requestID),
                  style: KType.headline.copyWith(color: c.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '# $_shortId',
                textDirection: TextDirection.ltr,
                style: KType.headline.copyWith(color: c.textSecondary),
              ),
            ],
          ),
          if (created != null) ...<Widget>[
            const SizedBox(height: KSpace.xs),
            Text(
              AppDateFormatter.dateFormate(created),
              style: KType.footnote.copyWith(color: c.textSecondary),
            ),
          ],
          const SizedBox(height: KSpace.m),
          OrderCustomerRow(order: order),
          if (order.location?.streetName != null) ...<Widget>[
            const SizedBox(height: KSpace.xs),
            OrderLocationRow(order: order),
          ],
          const SizedBox(height: KSpace.m),
          KButton(
            label: tr(context, AppStrings.viewDetails),
            variant: KButtonVariant.secondary,
            onPressed: () => _openDetails(context),
          ),
        ],
      ),
    );
  }
}
