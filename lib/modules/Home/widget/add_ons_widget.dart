import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_list_row.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';

/// The order's add-ons, inside the details screen's scroll view.
class AddOnsWidget extends StatelessWidget {
  final List<AddOns>? addOns;
  const AddOnsWidget({super.key, required this.addOns});

  static const double _iconSize = KSpace.xxxl + KSpace.s;

  @override
  Widget build(BuildContext context) {
    final String language = Localizations.localeOf(context).languageCode;
    final int cacheSize = (_iconSize * MediaQuery.devicePixelRatioOf(context))
        .round();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final AddOns addOn in addOns!)
          Padding(
            padding: const EdgeInsets.only(bottom: KSpace.m),
            child: KCard(
              padding: EdgeInsets.zero,
              child: KListRow(
                leading: SizedBox.square(
                  dimension: _iconSize,
                  child: CachedNetworkImage(
                    imageUrl: addOn.iconAddons!.iconLink!,
                    memCacheWidth: cacheSize,
                    errorWidget: (BuildContext context, String url, Object e) =>
                        const SizedBox.shrink(),
                  ),
                ),
                title: addOn.getLocalizedName(language) ?? '',
              ),
            ),
          ),
      ],
    );
  }
}
