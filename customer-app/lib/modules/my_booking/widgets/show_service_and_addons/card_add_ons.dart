import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/modules/Home/data/model/add_ons_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';

/// One add-on row inside the add-ons card.
class CardAddOns extends StatelessWidget {
  final AddOnsModel addOns;
  const CardAddOns({super.key, required this.addOns});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return KListRow(
      leading: ImageShared(
        image: addOns.icon?.iconLink ?? '',
        height: KSpace.xxl,
        width: KSpace.xxl,
      ),
      title: addOns.name!,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            addOns.price!.toString(),
            style: KType.headline.copyWith(color: c.text),
          ),
          const SizedBox(width: KSpace.xs),
          SvgPicture.asset(
            AssetsManager.saudiRiyalSymbol,
            height: KSpace.l,
            width: KSpace.l,
            colorFilter: ColorFilter.mode(c.text, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
