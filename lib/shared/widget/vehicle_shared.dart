import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/services/service_locator.dart';

/// A vehicle: its photo above solid details, with a brand outline when
/// selected.
class VehiclesCard extends StatelessWidget {
  final int index;
  final int selectedColor;
  final double? cardWidth;

  const VehiclesCard({
    super.key,
    required this.index,
    required this.selectedColor,
    this.cardWidth,
  });

  static const double _height = 200;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final vehicle = sl<VehiclesBloc>().vehiclesList[index];
    final bool isSelected =
        sl<VehiclesBloc>().selectedVehicle.sId == vehicle.sId;
    final TextStyle label = KType.footnote.copyWith(color: c.textSecondary);
    final TextStyle value = KType.footnote.copyWith(
      color: c.text,
      fontWeight: FontWeight.w600,
    );

    return SizedBox(
      width: cardWidth,
      height: _height,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShapeDecoration(
          shape: KRadius.shape(
            BorderRadius.circular(KRadius.card),
            side: isSelected
                ? BorderSide(color: c.brand, width: 2)
                : BorderSide.none,
          ),
        ),
        child: KCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: vehicle.imageLink!.isEmpty
                    ? ColoredBox(
                        color: c.fill,
                        child: Center(
                          child: Icon(
                            Icons.directions_car,
                            size: 48,
                            color: c.textSecondary,
                          ),
                        ),
                      )
                    : ImageShared(
                        image: vehicle.imageLink!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(KSpace.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: KType.headline.copyWith(color: c.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: KSpace.xs),
                    // Plate and colour share a line when they fit; on a narrow
                    // card they stack, so neither is cut off.
                    Wrap(
                      spacing: KSpace.m,
                      runSpacing: KSpace.xs,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(translate(AppStrings.plateNo), style: label),
                            const SizedBox(width: KSpace.xs),
                            Flexible(
                              child: Text(
                                vehicle.plateNumber ?? '',
                                style: value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(translate(AppStrings.color), style: label),
                            const SizedBox(width: KSpace.xs),
                            DecoratedBox(
                              decoration: ShapeDecoration(
                                color: selectedColor < 0
                                    ? c.fill
                                    : colorList[selectedColor].color,
                                shape: CircleBorder(
                                  side: selectedColor == 0
                                      ? BorderSide(color: c.separator)
                                      : BorderSide.none,
                                ),
                              ),
                              child: const SizedBox.square(dimension: KSpace.m),
                            ),
                            const SizedBox(width: KSpace.xs),
                            Flexible(
                              child: Text(
                                vehicle.color ?? '',
                                style: value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
