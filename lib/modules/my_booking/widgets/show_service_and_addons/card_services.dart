import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';

class CardServices extends StatefulWidget {
  final ServiceModel service;
  const CardServices({
    super.key,
    required this.service,
  });

  @override
  State<CardServices> createState() => _CardServicesState();
}

class _CardServicesState extends State<CardServices>
    with SingleTickerProviderStateMixin {
  bool showInfoPlan = true;
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      upperBound: 0.5,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _showInfo() {
    setState(() {
      showInfoPlan = !showInfoPlan;
      if (_controller.isDismissed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showInfo,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                widget.service.name!,
                style:
                    AppStyles.body14Medium.copyWith(color: ColorManager.black),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showInfo,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 32.h,
                  width: 32.w,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorManager.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: const Color.fromRGBO(0, 0, 0, .16),
                            blurRadius: 3.r,
                            offset: const Offset(0, 3))
                      ]),
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: ColorManager.primary,
                      size: 18.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: ColorManager.divider,
            thickness: 1,
            endIndent: 85.w,
          ),
          Row(
            children: <Widget>[
              Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                  color: ColorManager.gray,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.network(widget.service.icon != null
                    ? widget.service.icon!.iconLink!
                    : ""),
              ),
              9.pw,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SvgPicture.asset(
                        AssetsManager.timeIconLogo,
                        colorFilter: ColorFilter.mode(ColorManager.black, BlendMode.srcIn),
                      ),
                      AppPadding.p12.pw,
                      Text(
                        "${widget.service.duration!} ${translate(AppStrings.service)}",
                        style: AppStyles.caption12Medium
                            .copyWith(color: ColorManager.black),
                      ),
                    ],
                  ),
                  AppPadding.p8.ph,
                  Row(
                    children: <Widget>[
                      SvgPicture.asset(
                        AssetsManager.serviceCoinSvg,
                        colorFilter: ColorFilter.mode(ColorManager.black, BlendMode.srcIn),
                      ),
                      AppPadding.p12.pw,
                      Row(
                        children: [
                          Text(
                            "${widget.service.price!} ",
                            style: AppStyles.caption12Medium
                                .copyWith(color: ColorManager.black),
                          ),
                          SvgPicture.asset(
                            AssetsManager.saudiRiyalSymbol,
                            height: 12.h,
                            width: 12.w,
                          ),
                        ],
                      ),
                      // if (widget.service.pointsToPay != null) AppPadding.p12.pw,
                      // if (widget.service.pointsToPay != null)
                        // Row(
                        //   children: <Widget>[
                        //     SvgPicture.asset(
                        //       AssetsManager.walletCoin,
                        //     ),
                        //     2.pw,
                        //     Text(
                        //       "${widget.service.pointsToPay!}",
                        //       style: AppStyles.caption12Medium
                        //           .copyWith(color: ColorManager.black),
                        //     ),
                        //   ],
                        // )
                    ],
                  ),
                ],
              ),
            ],
          ),
          AppPadding.p8.ph,
          if (!showInfoPlan)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.service.description!.map((description) {
                return Row(
                  children: <Widget>[
                    Icon(
                      Icons.check,
                      color: ColorManager.darkGrey,
                      size: 16.w,
                    ),
                    13.pw,
                    Expanded(
                      child: Text(
                        description,
                        style: AppStyles.subtext14Regular
                            .copyWith(color: ColorManager.darkGrey),
                      ),
                    ),
                  ],
                );
              }).toList(),
            )
        ],
      ),
    );
  }
}
