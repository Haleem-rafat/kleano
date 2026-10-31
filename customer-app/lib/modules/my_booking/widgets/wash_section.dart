import 'package:flutter/material.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/tokens.dart';

/// A titled card on the wash details screen.
class WashSection extends StatelessWidget {
  const WashSection({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(KSpace.l),
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: KSpace.xs,
            bottom: KSpace.s,
          ),
          child: Text(
            title,
            style: KType.headline.copyWith(color: KColors.of(context).text),
          ),
        ),
        KCard(padding: padding, child: child),
      ],
    );
  }
}

/// Rows separated by hairlines that start after the leading icon.
class WashRows extends StatelessWidget {
  const WashRows({super.key, required this.rows});

  static const double _dividerIndent = KSpace.l + KSpace.xxl + KSpace.m;

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final Color separator = KColors.of(context).separator;
    return Column(
      children: <Widget>[
        for (int i = 0; i < rows.length; i++) ...<Widget>[
          if (i > 0)
            Divider(height: 1, indent: _dividerIndent, color: separator),
          rows[i],
        ],
      ],
    );
  }
}
