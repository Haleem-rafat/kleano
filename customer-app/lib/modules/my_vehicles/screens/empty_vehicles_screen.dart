import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

class EmptyVehiclesScreen extends StatelessWidget {
  final VoidCallback onPressed;
  const EmptyVehiclesScreen({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: KSpace.xxl),
          Text(
            translate(AppStrings.myVehicles),
            style: KType.title.copyWith(color: c.text),
          ),
          const SizedBox(height: KSpace.s),
          Text(
            translate(AppStrings.addCarInfo),
            style: KType.subhead.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: KSpace.xxxl),
          Center(
            child: SvgPicture.asset(
              AssetsManager.emptyCarSVG,
              colorFilter: ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: KSpace.xxxl),
          KButton(
            label: translate(AppStrings.addNewVehicles),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
