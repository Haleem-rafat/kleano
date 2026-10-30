import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../liquid_glass.dart';
import '../tokens.dart';

/// Layout for every auth / entry screen (approved design):
///
///  * brand header: purple gradient, white logo, optional [badge] ("Biker"),
///    optional glass back button; it shrinks while the keyboard is open,
///  * a sheet with a large [title], [subtitle] and the form [children]
///    (scrollable),
///  * [primaryAction] (and optional [secondaryAction]) pinned at the bottom,
///    always above the keyboard and the home indicator, never cut off.
class KAuthScaffold extends StatelessWidget {
  const KAuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    required this.primaryAction,
    this.secondaryAction,
    this.showBack = false,
    this.onBack,
    this.logoAsset = 'assets/svg/kleno_logo.svg',
    this.badge,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget primaryAction;
  final Widget? secondaryAction;
  final bool showBack;
  final VoidCallback? onBack;
  final String logoAsset;
  final String? badge;

  static const double _sheetOverlap = 28;
  static const double _collapsedHeader = 96;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final KColors c = KColors.of(context);
    final bool keyboard = mq.viewInsets.bottom > 0;
    final double header = keyboard
        ? _collapsedHeader
        : (mq.size.height * 0.26).clamp(160.0, 220.0);
    final double headerTotal = header + mq.padding.top;
    final double bottom =
        math.max(mq.viewInsets.bottom, mq.viewPadding.bottom) + KSpace.l;
    final Duration motion = KMotion.of(context, KMotion.normal);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // Insets are handled here so the header can shrink and the actions
        // stay pinned above the keyboard.
        resizeToAvoidBottomInset: false,
        backgroundColor: c.background,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: motion,
                curve: KMotion.curve,
                height: headerTotal,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.7, -0.9),
                    radius: 1.4,
                    colors: <Color>[
                      Color(0xFF8E5BA6),
                      Color(0xFF543063),
                      Color(0xFF2D1838),
                    ],
                    stops: <double>[0, 0.55, 1],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: AlignmentDirectional.bottomStart,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            KSpace.xxl,
                            0,
                            KSpace.xxl,
                            _sheetOverlap + KSpace.m,
                          ),
                          child: AnimatedOpacity(
                            duration: motion,
                            opacity: keyboard ? 0 : 1,
                            child: _Logo(asset: logoAsset, badge: badge),
                          ),
                        ),
                      ),
                      if (showBack)
                        PositionedDirectional(
                          start: KSpace.xs,
                          top: KSpace.xs,
                          child: GlassBackButton(
                            color: Colors.white,
                            onPressed: onBack,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: motion,
              curve: KMotion.curve,
              top: headerTotal - _sheetOverlap,
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: c.background,
                  shape: const RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(KRadius.sheet),
                    ),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          KSpace.xxl,
                          KSpace.xxl + KSpace.xs,
                          KSpace.xxl,
                          KSpace.l,
                        ),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              title,
                              style: KType.largeTitle.copyWith(
                                color: c.text,
                                fontSize: 30,
                              ),
                            ),
                            if (subtitle != null) ...<Widget>[
                              const SizedBox(height: KSpace.xs),
                              Text(
                                subtitle!,
                                style: KType.subhead.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                            const SizedBox(height: KSpace.xxl),
                            ...children,
                          ],
                        ),
                      ),
                    ),
                    AnimatedPadding(
                      duration: motion,
                      curve: KMotion.curve,
                      padding: EdgeInsets.fromLTRB(
                        KSpace.xxl,
                        KSpace.s,
                        KSpace.xxl,
                        bottom,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          primaryAction,
                          if (secondaryAction != null) ...<Widget>[
                            const SizedBox(height: KSpace.s),
                            secondaryAction!,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.asset, this.badge});

  final String asset;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SvgPicture.asset(asset, height: 48, excludeFromSemantics: true),
        if (badge != null)
          Padding(
            padding: const EdgeInsets.only(top: KSpace.xs),
            child: Text(
              badge!,
              style: KType.subhead.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
