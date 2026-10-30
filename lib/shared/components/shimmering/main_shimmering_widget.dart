import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class ShimmeringWidget extends StatelessWidget {
  final Widget child;

  const ShimmeringWidget({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      colorOpacity: 0.2,
      color: ColorManager.primary,
      duration: const Duration(milliseconds: 1000),
      direction: Localizations.localeOf(context).languageCode == 'en'
          ? const ShimmerDirection.fromLTRB()
          : const ShimmerDirection.fromRTLB(),
      child: child,
    );
  }
}
