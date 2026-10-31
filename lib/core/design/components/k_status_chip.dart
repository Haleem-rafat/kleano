import 'package:flutter/material.dart';

import '../tokens.dart';

enum KStatus { brand, success, warning, error, neutral }

/// Small capsule showing a status: 12% tinted background, label in a darker
/// shade of the status colour for contrast.
class KStatusChip extends StatelessWidget {
  const KStatusChip({super.key, required this.label, required this.status});

  final String label;
  final KStatus status;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final (Color base, Color label) = switch (status) {
      KStatus.brand => (c.brand, c.brand),
      KStatus.success => (
        c.success,
        dark ? c.success : const Color(0xFF1F8A3D),
      ),
      KStatus.warning => (
        c.warning,
        dark ? c.warning : const Color(0xFFC25E00),
      ),
      KStatus.error => (c.error, dark ? c.error : const Color(0xFFD70015)),
      KStatus.neutral => (c.textSecondary, c.textSecondary),
    };
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: base.withValues(alpha: 0.12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: KSpace.xs,
        ),
        child: Text(
          this.label,
          style: KType.footnote.copyWith(
            color: label,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
