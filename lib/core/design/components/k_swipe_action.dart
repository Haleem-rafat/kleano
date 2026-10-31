import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';

/// A one-way confirmation: drag the thumb to the far end to act. For steps that
/// must not fire on a stray tap. Follows the reading direction, and screen
/// readers get it as a plain button.
class KSwipeAction extends StatefulWidget {
  const KSwipeAction({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.loading = false,
  });

  final String label;

  /// Null shows the control disabled.
  final VoidCallback? onConfirmed;
  final bool loading;

  static const double height = 64;
  static const double _inset = KSpace.xs;
  static const double _confirmAt = 0.85;

  @override
  State<KSwipeAction> createState() => _KSwipeActionState();
}

class _KSwipeActionState extends State<KSwipeAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _position = AnimationController(vsync: this);

  bool get _enabled => widget.onConfirmed != null && !widget.loading;

  @override
  void didUpdateWidget(KSwipeAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loading && !widget.loading) _returnThumb();
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  void _returnThumb() {
    _position.animateTo(
      0,
      duration: KMotion.of(context, KMotion.normal),
      curve: KMotion.curve,
    );
  }

  void _onDragUpdate(DragUpdateDetails details, double travel) {
    final double sign = Directionality.of(context) == TextDirection.rtl
        ? -1
        : 1;
    _position.value += sign * details.primaryDelta! / travel;
  }

  void _onDragEnd() {
    if (_position.value < KSwipeAction._confirmAt) {
      _returnThumb();
      return;
    }
    _position.value = 1;
    HapticFeedback.mediumImpact();
    widget.onConfirmed!();
    // The action may open a sheet that can be cancelled: only stay at the end
    // while it reports loading.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.loading) _returnThumb();
    });
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final bool disabled = widget.onConfirmed == null;
    const double thumb = KSwipeAction.height - KSwipeAction._inset * 2;
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      onTap: _enabled ? widget.onConfirmed : null,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double travel =
              constraints.maxWidth - thumb - KSwipeAction._inset * 2;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: _enabled
                ? (DragUpdateDetails d) => _onDragUpdate(d, travel)
                : null,
            onHorizontalDragEnd: _enabled ? (_) => _onDragEnd() : null,
            child: AnimatedBuilder(
              animation: _position,
              builder: (BuildContext context, Widget? child) {
                final double p = _position.value;
                return SizedBox(
                  height: KSwipeAction.height,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            shape: const StadiumBorder(),
                            color: disabled ? c.fill : c.brandTint,
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start: 0,
                        top: 0,
                        bottom: 0,
                        width: thumb + KSwipeAction._inset * 2 + travel * p,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            shape: const StadiumBorder(),
                            color: disabled
                                ? c.fill
                                : c.brand.withValues(alpha: 0.28),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KSwipeAction.height,
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: (1 - p * 1.6).clamp(0.0, 1.0),
                              child: Text(
                                widget.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: KType.headline.copyWith(
                                  color: disabled
                                      ? c.textSecondary
                                      : c.onBrandTint,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start: KSwipeAction._inset + travel * p,
                        top: KSwipeAction._inset,
                        child: SizedBox.square(
                          dimension: thumb,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: disabled ? c.separator : c.brand,
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Center(
                child: widget.loading
                    ? SizedBox.square(
                        dimension: KSpace.xxl,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(c.surface),
                        ),
                      )
                    : Icon(Icons.arrow_forward, color: c.surface),
              ),
            ),
          );
        },
      ),
    );
  }
}
