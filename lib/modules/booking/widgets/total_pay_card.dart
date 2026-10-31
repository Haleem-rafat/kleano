import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/tokens.dart';

/// The booking action, carrying the total ("Next · 25"): one solid primary
/// button floating above the tab bar.
class TotalPayCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final int servicesCount;
  final int addOnsCount;
  final num servicesTotal;
  final num addOnsTotal;
  final num totalPrice;
  const TotalPayCard({
    super.key,
    this.onTap,
    required this.text,
    required this.servicesCount,
    required this.addOnsCount,
    required this.servicesTotal,
    required this.addOnsTotal,
    required this.totalPrice,
  });

  String _formatPrice(num value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KSpace.xl),
      child: KButton(
        label: totalPrice > 0
            ? '$text · ${_formatPrice(totalPrice)} ${translate(AppStrings.sAR)}'
            : text,
        onPressed: onTap ?? () {},
      ),
    );
  }
}
