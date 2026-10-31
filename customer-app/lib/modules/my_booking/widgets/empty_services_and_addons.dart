import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/tokens.dart';

/// An empty state that keeps the app's own SVG illustration, laid out like
/// `KEmptyState` (which only takes an `IconData`).
class EmptyScreen extends StatelessWidget {
  final String image;
  final String text;
  const EmptyScreen({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(KSpace.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.asset(
            image,
            colorFilter: ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
          ),
          const SizedBox(height: KSpace.m),
          Text(
            translate(text),
            textAlign: TextAlign.center,
            style: KType.subhead.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
