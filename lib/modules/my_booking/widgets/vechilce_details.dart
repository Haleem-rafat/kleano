import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/widgets/wash_section.dart';
import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';

class VechilceDetails extends StatelessWidget {
  static const double _photoHeight = 140;

  final Vehicle vehicle;
  const VechilceDetails({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return WashSection(
      title: '${vehicle.brand!} ${vehicle.model}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: KSpace.xs,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(KRadius.field),
            child: SizedBox(
              height: _photoHeight,
              child: vehicle.imageLink!.isEmpty
                  ? ColoredBox(
                      color: c.fill,
                      child: Icon(Icons.image, color: c.textSecondary),
                    )
                  : ImageShared(
                      image: vehicle.imageLink!,
                      width: double.infinity,
                      height: _photoHeight,
                    ),
            ),
          ),
          const SizedBox(height: KSpace.xs),
          VehicleInfoLine(
            label: translate(AppStrings.plateNo),
            value: vehicle.plateNumber!,
          ),
          VehicleColorLine(color: vehicle.color!),
        ],
      ),
    );
  }
}

/// "Label  value" in small type, used in booking cards and wash details.
class VehicleInfoLine extends StatelessWidget {
  const VehicleInfoLine({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Text.rich(
      TextSpan(
        text: '$label  ',
        style: KType.footnote.copyWith(color: c.textSecondary),
        children: <InlineSpan>[
          TextSpan(
            text: value,
            style: KType.footnote.copyWith(
              color: c.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// The car's colour: a dot in that colour and its name.
class VehicleColorLine extends StatelessWidget {
  const VehicleColorLine({super.key, required this.color});

  static const double _dotSize = 10;

  final String color;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final int index = colorList.indexWhere(
      (ColorType element) => element.colorName == color,
    );
    final ColorType match = colorList[index == -1 ? 0 : index];
    return Row(
      children: <Widget>[
        Text(
          translate(AppStrings.color),
          style: KType.footnote.copyWith(color: c.textSecondary),
        ),
        const SizedBox(width: KSpace.s),
        DecoratedBox(
          decoration: ShapeDecoration(
            color: match.color,
            shape: CircleBorder(side: BorderSide(color: c.separator)),
          ),
          child: const SizedBox.square(dimension: _dotSize),
        ),
        const SizedBox(width: KSpace.xs),
        Flexible(
          child: Text(
            color,
            style: KType.footnote.copyWith(
              color: c.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
