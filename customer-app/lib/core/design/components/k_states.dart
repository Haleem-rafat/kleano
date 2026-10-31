import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../liquid_glass.dart';
import '../tokens.dart';
import 'k_button.dart';
import 'k_card.dart';

/// Shown when a list or screen has nothing to show yet.
class KEmptyState extends StatelessWidget {
  const KEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => _StateLayout(
    icon: icon,
    title: title,
    message: message,
    action: actionLabel == null
        ? null
        : KButton(label: actionLabel!, onPressed: onAction, expand: false),
  );
}

/// A spinner for a short wait with no content shape. Lists and screens use
/// [KSkeleton].
class KLoadingState extends StatelessWidget {
  const KLoadingState({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(KSpace.xxl),
      child: GlassTokens.useNative
          ? const CupertinoActivityIndicator(radius: 14)
          : const CircularProgressIndicator(),
    ),
  );
}

/// Grey placeholders in the shape of the content on its way, for screens and
/// lists. [KLoadingState] stays for short waits that have no content shape
/// (placing an order, a map search). One pulse for the whole group; still when
/// the user asked for reduced motion.
class KSkeleton extends StatefulWidget {
  /// Rows such as bookings, notifications or addresses.
  const KSkeleton.list({
    super.key,
    this.count = 5,
    this.padding = const EdgeInsets.all(KSpace.l),
  }) : _kind = _KSkeletonKind.list;

  /// A title above three-column photo tiles: Home's services.
  const KSkeleton.grid({
    super.key,
    this.count = 3,
    this.padding = const EdgeInsets.all(KSpace.l),
  }) : _kind = _KSkeletonKind.grid;

  /// A large card and rows: details, profile and text screens.
  const KSkeleton.details({
    super.key,
    this.padding = const EdgeInsets.all(KSpace.l),
  }) : count = 2,
       _kind = _KSkeletonKind.details;

  final int count;
  final EdgeInsetsGeometry padding;
  final _KSkeletonKind _kind;

  @override
  State<KSkeleton> createState() => _KSkeletonState();
}

enum _KSkeletonKind { list, grid, details }

class _KSkeletonState extends State<KSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.65,
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse
        ..stop()
        ..value = 1;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Widget _row() => KCard(
    child: Row(
      children: <Widget>[
        const _Block(
          width: KSpace.xxxl + KSpace.s,
          height: KSpace.xxxl + KSpace.s,
        ),
        const SizedBox(width: KSpace.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              FractionallySizedBox(
                widthFactor: 0.6,
                child: _Block(height: KSpace.m),
              ),
              SizedBox(height: KSpace.s),
              _Block(height: KSpace.m),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _tile() => KCard(
    padding: EdgeInsets.zero,
    child: AspectRatio(
      aspectRatio: 0.72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const <Widget>[
          Expanded(child: _Block(radius: 0)),
          Padding(
            padding: EdgeInsets.all(KSpace.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _Block(height: KSpace.m),
                SizedBox(height: KSpace.xs),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: _Block(height: KSpace.s),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  List<Widget> _grid() {
    const int columns = 3;
    final int rows = (widget.count / columns).ceil();
    return <Widget>[
      const FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: 0.55,
        child: _Block(height: KSpace.xl),
      ),
      for (int row = 0; row < rows; row++) ...<Widget>[
        const SizedBox(height: KSpace.m),
        Row(
          children: <Widget>[
            for (int column = 0; column < columns; column++) ...<Widget>[
              if (column > 0) const SizedBox(width: KSpace.s),
              Expanded(child: _tile()),
            ],
          ],
        ),
      ],
    ];
  }

  List<Widget> _rows(int count) => <Widget>[
    for (int i = 0; i < count; i++) ...<Widget>[
      if (i > 0) const SizedBox(height: KSpace.m),
      _row(),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = switch (widget._kind) {
      _KSkeletonKind.list => _rows(widget.count),
      _KSkeletonKind.grid => _grid(),
      _KSkeletonKind.details => <Widget>[
        const _Block(height: KSpace.xxxl * 4, radius: KRadius.card),
        const SizedBox(height: KSpace.m),
        ..._rows(widget.count),
      ],
    };
    // Scrollable so a short window clips the placeholders without an overflow.
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: FadeTransition(
          opacity: _pulse,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: widget.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({this.width, this.height, this.radius = KRadius.field});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: ShapeDecoration(
        shape: KRadius.shape(BorderRadius.circular(radius)),
        color: KColors.of(context).fill,
      ),
    ),
  );
}

/// Shown when loading failed; offers a retry.
class KErrorState extends StatelessWidget {
  const KErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _StateLayout(
    icon: Icons.wifi_off_rounded,
    title: message,
    action: KButton(
      key: const ValueKey<String>('k-error-retry'),
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      variant: KButtonVariant.secondary,
      onPressed: onRetry,
      expand: false,
    ),
  );
}

class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: c.textSecondary),
            const SizedBox(height: KSpace.m),
            Text(
              title,
              textAlign: TextAlign.center,
              style: KType.headline.copyWith(color: c.text),
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: KSpace.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: KType.subhead.copyWith(color: c.textSecondary),
              ),
            ],
            if (action != null) ...<Widget>[
              const SizedBox(height: KSpace.l),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
