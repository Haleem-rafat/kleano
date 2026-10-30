import 'package:flutter/material.dart';

import '../tokens.dart';

/// Grouped-list row: at least 44pt tall, optional leading/trailing widgets and
/// a chevron that mirrors in right-to-left languages.
class KListRow extends StatelessWidget {
  const KListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: KSpace.tapTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpace.l, vertical: KSpace.m),
          child: Row(
            children: <Widget>[
              if (leading != null) ...<Widget>[
                leading!,
                const SizedBox(width: KSpace.m),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(title, style: KType.body.copyWith(color: c.text)),
                    if (subtitle != null)
                      Text(subtitle!, style: KType.subhead.copyWith(color: c.textSecondary)),
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: KSpace.s),
                trailing!,
              ],
              if (showChevron)
                Icon(
                  Icons.chevron_right,
                  key: const ValueKey<String>('k-list-row-chevron'),
                  color: c.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
