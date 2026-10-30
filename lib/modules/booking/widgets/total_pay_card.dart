import 'package:flutter/material.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/tokens.dart';

/// The Home booking action (design: CustomerHome): one primary [KButton] —
/// Apple prominent glass on iOS, Material 3 filled on Android — that carries
/// the total, e.g. "Next · 25". Replaces the old gradient card.
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
      padding: const EdgeInsets.symmetric(
          horizontal: KSpace.xl, vertical: KSpace.l),
      child: KButton(
        label: totalPrice > 0 ? '$text · ${_formatPrice(totalPrice)}' : text,
        onPressed: onTap ?? () {},
      ),
    );
  }
}
