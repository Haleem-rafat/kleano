import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class MainServices extends StatefulWidget {
  final List<ServiceModel> mainServices;
  final Function(int index)? addOrRemoveMainServices;
  const MainServices({
    super.key,
    required this.mainServices,
    this.addOrRemoveMainServices,
  });

  @override
  State<MainServices> createState() => _MainServicesState();
}

class _MainServicesState extends State<MainServices> {
  Map<int, bool> expandedStates = {};

  Widget _buildDetailItem({
    required String icon,
    required String text,
    Color? color,
    Widget? suffix,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(icon, height: 14.h, width: 14.w, colorFilter: color == null ? null : ColorFilter.mode(color, BlendMode.srcIn)),
        SizedBox(width: 6.w),
        Text(
          text,
          style: AppStyles.caption12Medium.copyWith(color: ColorManager.black),
        ),
        if (suffix != null) ...[SizedBox(width: 2.w), suffix],
      ],
    );
  }

  Widget _buildDescriptionItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6.h, right: 8.w),
            height: 4.h,
            width: 4.w,
            decoration: BoxDecoration(
              color: ColorManager.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppStyles.caption12Medium.copyWith(
                color: ColorManager.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offersBloc = sl<OffersBloc>();
    return BlocBuilder<OffersBloc, OffersState>(
      bloc: offersBloc,
      builder: (context, state) {
        if (state is OffersInitial ||
            state is GetServicesLoading ||
            state is GetGuestServicesLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppMargin.m16.h),
            child: Center(
              child: SizedBox(
                width: 28.w,
                height: 28.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(ColorManager.primary),
                ),
              ),
            ),
          );
        }

        if (widget.mainServices.isEmpty) {
          return const SizedBox();
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.mainServices.length,
          itemBuilder: (context, index) {
            final service = widget.mainServices[index];
            if (service.name == "1") {
              return const SizedBox.shrink();
            }
            final bool isSelected = offersBloc.cartServicesList.contains(
              service,
            );
            final List<dynamic>? description =
                service.description as List<dynamic>?;

            return AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTapDown: (_) {
                  // Add haptic feedback for better UX
                  HapticFeedback.lightImpact();
                },
                onTap: () {
                  if (isSelected) {
                    int deleteIndex = offersBloc.cartServicesList.indexOf(
                      service,
                    );
                    offersBloc.add(
                      DeleteServiceCart(index: deleteIndex, service: service),
                    );
                  } else {
                    offersBloc.add(
                      AddServiceCart(
                        service: service,
                        selectedMainServiceIndex: index,
                      ),
                    );
                  }
                  widget.addOrRemoveMainServices?.call(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(vertical: AppMargin.m8.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? ColorManager.secondary
                          : ColorManager.lightGray,
                      width: isSelected ? 2.w : 1.w,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    color: ColorManager.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: isSelected
                            ? ColorManager.secondary.withValues(alpha: 0.15)
                            : ColorManager.black.withValues(alpha: 0.08),
                        blurRadius: isSelected ? 8.r : 4.r,
                        offset: Offset(0, isSelected ? 4.h : 2.h),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Radio Button
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: SizedBox(
                              height: AppSize.s20.h,
                              width: AppSize.s20.w,
                              child: RadioGroup<int>(
                                groupValue: isSelected ? index : null,
                                onChanged: (int? value) {
                                  if (value != null) {
                                    if (isSelected) {
                                      int deleteIndex = offersBloc
                                          .cartServicesList
                                          .indexOf(service);
                                      offersBloc.add(
                                        DeleteServiceCart(
                                          index: deleteIndex,
                                          service: service,
                                        ),
                                      );
                                    } else {
                                      offersBloc.add(
                                        AddServiceCart(
                                          service: service,
                                          selectedMainServiceIndex: index,
                                        ),
                                      );
                                    }
                                    widget.addOrRemoveMainServices?.call(index);
                                  }
                                },
                                child: Radio<int>(
                                  value: index,
                                  activeColor: ColorManager.primary,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // Service Icon
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: ColorManager.gray,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: ColorManager.lightGray,
                                width: 1.w,
                              ),
                            ),
                            child: ImageShared(
                              image: service.icon?.iconLink ?? '',
                              height: 48.h,
                              width: 48.w,
                            ),
                          ),
                          SizedBox(width: 16.w),

                          // Service Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Service Name
                                Text(
                                  service.name ?? '',
                                  style: AppStyles.body14Medium.copyWith(
                                    color: ColorManager.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.h),

                                // Service Details Grid
                                Wrap(
                                  spacing: 16.w,
                                  runSpacing: 6.h,
                                  children: [
                                    // Points
                                    // _buildDetailItem(
                                    //   icon: AssetsManager.walletCoin,
                                    //   text: widget
                                    //       .mainServices[index].pointsToPay
                                    //       .toString(),
                                    // ),

                                    // Duration
                                    if (service.duration != null)
                                      _buildDetailItem(
                                        color: ColorManager.black,
                                        icon: AssetsManager.timeIconLogo,
                                        text:
                                            "${service.duration} ${translate(service.durationUnit ?? '')} ${translate(AppStrings.toService)}",
                                      ),

                                    // Price
                                    _buildDetailItem(
                                      color: ColorManager.black,
                                      icon: AssetsManager.serviceCoinSvg,
                                      text: "${service.price ?? ''} ",
                                      suffix: SvgPicture.asset(
                                        AssetsManager.saudiRiyalSymbol,
                                        height: 12.h,
                                        width: 12.w,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Description Section with Enhanced Design
                      if (description?.isNotEmpty == true)
                        Container(
                          margin: EdgeInsets.only(top: 12.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: ColorManager.gray.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: ColorManager.lightGray,
                              width: 1.w,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Description Title
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16.h,
                                    color: ColorManager.primary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    translate('serviceDetails'),
                                    style: AppStyles.caption12Medium.copyWith(
                                      color: ColorManager.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),

                              // Description Items
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Show first item always
                                  _buildDescriptionItem(
                                    description?[0]?.toString() ?? '',
                                  ),
                                  // Show additional items only when expanded
                                  if (expandedStates[index] == true)
                                    ...List.generate(
                                      (description?.length ?? 1) - 1,
                                      (i) => _buildDescriptionItem(
                                        description?[i + 1]?.toString() ?? '',
                                      ),
                                    ),
                                ],
                              ),

                              // Show see more/hide button only if there are multiple items
                              if ((description?.length ?? 0) > 1) ...[
                                SizedBox(height: 8.h),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      expandedStates[index] =
                                          !(expandedStates[index] ?? false);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4.h,
                                      horizontal: 8.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ColorManager.primary.withValues(alpha: 
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          expandedStates[index] == true
                                              ? translate('hide')
                                              : translate('seeMore'),
                                          style: AppStyles.caption12Medium
                                              .copyWith(
                                                color: ColorManager.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Icon(
                                          expandedStates[index] == true
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          size: 16.h,
                                          color: ColorManager.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
