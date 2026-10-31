import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/tracking_order/data/models/accepted_biker_model.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/contact_biker.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';

class BikerInformation extends StatelessWidget {
  final Biker biker;
  final String status;
  const BikerInformation({
    super.key,
    required this.biker,
    required this.status,
  });

  static const double _photoSize = 48;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(KSpace.l),
      child: Row(
        children: <Widget>[
          ClipOval(
            child: biker.imageLink!.isEmpty
                ? ColoredBox(
                    color: c.fill,
                    child: SizedBox.square(
                      dimension: _photoSize,
                      child: Icon(Icons.person, color: c.textSecondary),
                    ),
                  )
                : ImageShared(
                    image: biker.imageLink!,
                    height: _photoSize,
                    width: _photoSize,
                  ),
          ),
          const SizedBox(width: KSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  translate(AppStrings.biker),
                  style: KType.footnote.copyWith(color: c.textSecondary),
                ),
                Text(
                  biker.userName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KType.headline.copyWith(color: c.text),
                ),
              ],
            ),
          ),
          const SizedBox(width: KSpace.s),
          ContactBiker(phoneBiker: biker.phone!),
        ],
      ),
    );
  }
}
