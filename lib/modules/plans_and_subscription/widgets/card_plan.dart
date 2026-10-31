import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/plans_model.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/price_and_points.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/subscribe_button.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';

/// A subscription plan: icon, name, washes and price at a glance, opening to
/// show what it includes and the subscribe button. The colour comes from the plan's data
/// and only tints its icons and its outline.
class CardOfPlan extends StatefulWidget {
  final Plan plan;
  final bool userHaveAPlan;
  final bool comeformBooking;
  final bool showExpandableContent;
  final bool isHighlighted;

  const CardOfPlan({
    super.key,
    required this.plan,
    required this.userHaveAPlan,
    this.comeformBooking = false,
    this.showExpandableContent = true,
    this.isHighlighted = false,
  });

  @override
  State<CardOfPlan> createState() => _CardOfPlanState();
}

class _CardOfPlanState extends State<CardOfPlan> {
  static const double _iconTileSize = 56;
  static const double _iconSize = KSpace.xxxl;
  static const double _bulletSize = 20;

  bool _isExpanded = false;

  final GetUserProfileBloc _getUserProfileBloc = sl<GetUserProfileBloc>();

  void _toggleExpansion() => setState(() => _isExpanded = !_isExpanded);

  Color get _planColor => Color(int.parse("0xFF${widget.plan.color!}"));

  bool get _isSubscribed =>
      AppShared.token.isNotEmpty &&
      (widget.comeformBooking
          ? _getUserProfileBloc.profile.isSubscribed!
          : widget.plan.isSubscribed!);

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final Color planColor = _planColor;
    final bool isSubscribed = _isSubscribed;
    final Duration duration = KMotion.of(context, KMotion.normal);
    final bool expandable = widget.showExpandableContent;

    final Widget card = KCard(
      onTap: expandable ? _toggleExpansion : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              _PlanIcon(
                plan: widget.plan,
                color: planColor,
                tileSize: _iconTileSize,
                iconSize: _iconSize,
              ),
              const SizedBox(width: KSpace.m),
              Expanded(child: _title(c, isSubscribed)),
              if (expandable)
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: duration,
                  curve: KMotion.curve,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: c.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: KSpace.m),
          PriceAndPoints(
            price: widget.plan.price!,
            durationUnit: widget.plan.durationUnit!,
            pointsToPay: widget.plan.pointsToPay!,
            duration: widget.plan.duration!,
          ),
          AnimatedSize(
            duration: duration,
            curve: KMotion.curve,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? _details(c, planColor, isSubscribed)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        // Home lines the card up with its own sections.
        horizontal: widget.comeformBooking ? KSpace.l : KSpace.xl,
        vertical: KSpace.s,
      ),
      child: widget.isHighlighted || isSubscribed
          ? Container(
              foregroundDecoration: ShapeDecoration(
                shape: KRadius.shape(
                  BorderRadius.circular(KRadius.card),
                  side: BorderSide(
                    color: widget.isHighlighted
                        ? planColor
                        : planColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              child: card,
            )
          : card,
    );
  }

  Widget _title(KColors c, bool isSubscribed) {
    final int points = widget.plan.pointsToPay ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.plan.type!, style: KType.headline.copyWith(color: c.text)),
        if (widget.plan.usageCount != null)
          Text(
            '${widget.plan.usageCount} ${translate(AppStrings.washes)}',
            style: KType.subhead.copyWith(color: c.textSecondary),
          ),
        if (points > 0 || isSubscribed) ...<Widget>[
          const SizedBox(height: KSpace.xs),
          Wrap(
            spacing: KSpace.s,
            runSpacing: KSpace.xs,
            children: <Widget>[
              if (points > 0)
                KStatusChip(
                  label: '$points ${translate(AppStrings.points)}',
                  status: KStatus.neutral,
                ),
              if (isSubscribed)
                KStatusChip(
                  label: translate(AppStrings.active),
                  status: KStatus.success,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _details(KColors c, Color planColor, bool isSubscribed) {
    final Plan plan = widget.plan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Divider(height: KSpace.xxxl, color: c.separator),
        if (plan.description?.isNotEmpty == true) ...<Widget>[
          _sectionLabel(c, translate(AppStrings.description)),
          for (final String description in plan.description!)
            _bulletRow(
              c,
              text: description,
              bullet: Icon(Icons.circle, size: 6, color: planColor),
            ),
        ],
        if (plan.washingServices?.isNotEmpty == true) ...<Widget>[
          const SizedBox(height: KSpace.l),
          _sectionLabel(c, translate(AppStrings.services)),
          for (final WashingServices service in plan.washingServices!)
            _bulletRow(
              c,
              text: service.name!,
              bullet: Icon(
                Icons.check_rounded,
                size: KSpace.l,
                color: planColor,
              ),
            ),
        ],
        const SizedBox(height: KSpace.l),
        SubscribeButton(
          createdAt: plan.createdAt ?? "",
          userHaveAPlan: widget.userHaveAPlan,
          planId: plan.sId!,
          planType: plan.type!,
          planPrice: plan.price!.toDouble(),
          isSubscribed: isSubscribed,
          comeformBooking: widget.comeformBooking,
        ),
      ],
    );
  }

  Widget _sectionLabel(KColors c, String text) => Padding(
    padding: const EdgeInsets.only(bottom: KSpace.s),
    child: Text(
      text,
      style: KType.footnote.copyWith(
        color: c.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _bulletRow(
    KColors c, {
    required String text,
    required Widget bullet,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: KSpace.s),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox.square(
          dimension: _bulletSize,
          child: Center(child: bullet),
        ),
        const SizedBox(width: KSpace.s),
        Expanded(
          child: Text(text, style: KType.subhead.copyWith(color: c.text)),
        ),
      ],
    ),
  );
}

class _PlanIcon extends StatelessWidget {
  const _PlanIcon({
    required this.plan,
    required this.color,
    required this.tileSize,
    required this.iconSize,
  });

  final Plan plan;
  final Color color;
  final double tileSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final String? link = plan.icon?.iconLink;
    final Widget fallback = SvgPicture.asset(
      AssetsManager.carWash,
      width: iconSize,
      height: iconSize,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.1),
        shape: KRadius.shape(BorderRadius.circular(KRadius.field)),
      ),
      child: SizedBox.square(
        dimension: tileSize,
        child: Center(
          child: link == null || link.isEmpty
              ? fallback
              : ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: link,
                    width: iconSize,
                    height: iconSize,
                    memCacheWidth: 150,
                    errorWidget: (BuildContext _, String _, Object _) =>
                        fallback,
                  ),
                ),
        ),
      ),
    );
  }
}
