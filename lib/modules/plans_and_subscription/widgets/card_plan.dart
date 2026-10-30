import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/plans_model.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/price_and_points.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/subscribe_button.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';

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

class _CardOfPlanState extends State<CardOfPlan> with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late AnimationController _scaleController;
  late Animation<double> _expandAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final _getUserProfileBloc = sl<GetUserProfileBloc>();

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutQuart,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _expandController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    if (widget.showExpandableContent) {
      setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) {
          _expandController.forward();
        } else {
          _expandController.reverse();
        }
      });
    }
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  Color get _planColor => Color(int.parse("0xFF${widget.plan.color!}"));

  bool get _isSubscribed =>
      AppShared.token.isNotEmpty &&
      (widget.comeformBooking
          ? _getUserProfileBloc.profile.isSubscribed!
          : widget.plan.isSubscribed!);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: GestureDetector(
          onTap: _toggleExpansion,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          behavior: HitTestBehavior.opaque,
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppMargin.m24.w,
        vertical: AppMargin.m12.h,
      ),
      decoration: _cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              _buildHeader(),
              _buildExpandableContent(),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    final bool highlight = widget.isHighlighted;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20.r),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          ColorManager.backGround,
          ColorManager.backGround.withOpacity(0.98),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: highlight
              ? _planColor.withOpacity(0.35)
              : _planColor.withOpacity(0.1),
          blurRadius: highlight ? 28.r : 20.r,
          offset: Offset(0, highlight ? 14.h : 10.h),
          spreadRadius: highlight ? 2.r : -5.r,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10.r,
          offset: Offset(0, 4.h),
          spreadRadius: 0,
        ),
      ],
      border: Border.all(
        color: highlight
            ? _planColor
            : _isSubscribed
                ? _planColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
        width: highlight
            ? 3.w
            : _isSubscribed
                ? 2.w
                : 1.w,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          _buildPlanIcon(),
          16.pw,
          Expanded(child: _buildPlanTitle()),
          if (widget.showExpandableContent) _buildExpandButton(),
        ],
      ),
    );
  }

  Widget _buildPlanIcon() {
    return Hero(
      tag: 'plan_icon_${widget.plan.sId}',
      child: Container(
        width: 64.r,
        height: 64.r,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _planColor.withOpacity(0.1),
              _planColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _planColor.withOpacity(0.2),
            width: 1.w,
          ),
        ),
        child: Center(
          child: _buildIconWidget(),
        ),
      ),
    );
  }

  Widget _buildIconWidget() {
    // Use plan's custom icon if available, otherwise fallback to default
    if (widget.plan.icon?.iconLink != null &&
        widget.plan.icon!.iconLink!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: _planColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(99.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(99.r),
          child: CachedNetworkImage(
            imageUrl: widget.plan.icon!.iconLink!,
            width: 40.r,
            height: 40.r,
            errorWidget: (context, url, error) => _buildDefaultIcon(),
          ),
        ),
      );
    } else {
      return _buildDefaultIcon();
    }
  }

  Widget _buildDefaultIcon() {
    return SvgPicture.asset(
      AssetsManager.planColor,
      width: 32.r,
      height: 32.r,
      color: _planColor,
    );
  }

  Widget _buildPlanTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.plan.type!,
          style: AppStyles.title16Bold.copyWith(
            color: _planColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        4.ph,
        Row(
          children: [
            if (widget.plan.pointsToPay != null &&
                widget.plan.pointsToPay! > 0) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _planColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      size: 14.r,
                      color: _planColor,
                    ),
                    4.pw,
                    Text(
                      '${widget.plan.pointsToPay} points',
                      style: AppStyles.body14Medium.copyWith(
                        color: _planColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSubscribed) 8.pw,
            ],
            if (_isSubscribed)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _planColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Active',
                  style: AppStyles.body14Medium.copyWith(
                    color: _planColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandButton() {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) => Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: _planColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Transform.rotate(
            angle: _expandAnimation.value * 3.14159, // 180 degrees in radians
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _planColor,
              size: 24.r,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableContent() {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                color: Colors.grey.withOpacity(0.2),
                thickness: 1.h,
                height: 1.h,
              ),
              20.ph,
              _buildUsageInfo(),
              if (widget.plan.description?.isNotEmpty == true) ...[
                16.ph,
                _buildDescriptionSection(),
              ],
              if (widget.plan.washingServices?.isNotEmpty == true) ...[
                16.ph,
                _buildServicesList(),
              ],
              24.ph,
              PriceAndPoints(
                price: widget.plan.price!,
                durationUnit: widget.plan.durationUnit!,
                pointsToPay: widget.plan.pointsToPay!,
                duration: widget.plan.duration!,
              ),
              20.ph,
              SubscribeButton(
                createdAt: widget.plan.createdAt ?? "",
                userHaveAPlan: widget.userHaveAPlan,
                planId: widget.plan.sId!,
                planType: widget.plan.type!,
                planPrice: widget.plan.price!.toDouble(),
                isSubscribed: _isSubscribed,
                comeformBooking: widget.comeformBooking,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageInfo() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: _planColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _planColor.withOpacity(0.1),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: _planColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
                child: SvgPicture.asset(
              AssetsManager.carWash,
              width: 24.w,
              height: 24.h,
              color: _planColor,
            )),
          ),
          12.pw,
          Text(
            '${widget.plan.usageCount!} ${translate(AppStrings.washes)}',
            style: AppStyles.body14Medium.copyWith(
              color: const Color(0xFF515151),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppStyles.body14Medium.copyWith(
            color: Colors.grey[700],
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        8.ph,
        ...widget.plan.description!.asMap().entries.map((entry) {
          final index = entry.key;
          final description = entry.value;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) => Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          color: _planColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.circle,
                            size: 6.r,
                            color: _planColor,
                          ),
                        ),
                      ),
                      12.pw,
                      Expanded(
                        child: Text(
                          description,
                          style: AppStyles.subtext14Regular.copyWith(
                            color: Colors.grey[600],
                            fontSize: 14.sp,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildServicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Included Services',
          style: AppStyles.body14Medium.copyWith(
            color: Colors.grey[700],
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        8.ph,
        ...widget.plan.washingServices!.asMap().entries.map((entry) {
          final index = entry.key;
          final service = entry.value;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) => Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          color: _planColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 14.r,
                            color: _planColor,
                          ),
                        ),
                      ),
                      12.pw,
                      Expanded(
                        child: Text(
                          service.name!,
                          style: AppStyles.subtext14Regular.copyWith(
                            color: Colors.grey[600],
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
