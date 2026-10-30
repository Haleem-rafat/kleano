import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/profile/data/models/promo_code_model.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/pormo_codes_screen.dart';
import 'package:thewasher/modules/profile/widgets/button_use_promo.dart';

class PromoContainerWidget extends StatefulWidget {
  final PromoCodeModel promoCodeModel;
  final String type;
  final bool isVisible;
  final bool isHighlighted;
  const PromoContainerWidget(
      {Key? key,
      required this.type,
      required this.promoCodeModel,
      required this.isVisible,
      this.isHighlighted = false})
      : super(key: key);

  @override
  State<PromoContainerWidget> createState() => _PromoContainerWidgetState();
}

class _PromoContainerWidgetState extends State<PromoContainerWidget> {
  @override
  void initState() {
    super.initState();
  }

  // Helper method to get the appropriate discount value and type
  Map<String, dynamic> getDiscountInfo() {
    if (widget.promoCodeModel.discountFixedNumber != null) {
      return {
        'value': widget.promoCodeModel.discountFixedNumber!,
        'type': 'fixed',
        'displayText': '${widget.promoCodeModel.discountFixedNumber}',
        'showSvg': true
      };
    } else if (widget.promoCodeModel.discountPercentage != null) {
      return {
        'value': widget.promoCodeModel.discountPercentage!,
        'type': 'percentage',
        'displayText': '${widget.promoCodeModel.discountPercentage} %'
      };
    } else {
      return {
        'value': 0,
        'type': 'none',
        'displayText': '${translate(AppStrings.promoTitle)}'
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final discountInfo = getDiscountInfo();
    final bool highlight = widget.isHighlighted;

    Color _resolveTypeColor() {
      if (widget.type == PromoCodeTypes.expired.name) {
        return ColorManager.red;
      } else if (widget.type == PromoCodeTypes.used.name) {
        return ColorManager.darkGrey;
      }
      return ColorManager.primary;
    }

    final Color typeColor = _resolveTypeColor();
    final Color borderColor =
        highlight ? ColorManager.primary : typeColor.withOpacity(0.7);
    final List<BoxShadow> boxShadows = highlight
        ? <BoxShadow>[
            BoxShadow(
              color: ColorManager.primary.withOpacity(.2),
              blurRadius: 18.r,
              offset: const Offset(0, 8),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: widget.type == PromoCodeTypes.active.name ||
                      widget.type == PromoCodeTypes.used.name
                  ? ColorManager.primary.withOpacity(.08)
                  : ColorManager.black.withOpacity(.05),
              blurRadius: 8.r,
              offset: const Offset(0, 4),
            ),
          ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: highlight
            ? ColorManager.primary.withOpacity(0.05)
            : ColorManager.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: borderColor,
          width: highlight ? 2 : 1,
        ),
        boxShadow: boxShadows,
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.isVisible) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: ColorManager.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: ColorManager.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 16.sp,
                    color: ColorManager.primary,
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: Text(
                      widget.promoCodeModel.code ?? "",
                      style: AppStyles.body14Medium.copyWith(
                        color: ColorManager.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            12.ph,
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${discountInfo['displayText']} ",
                          style: AppStyles.title16Bold.copyWith(
                            color: widget.type == PromoCodeTypes.active.name ||
                                    widget.type == PromoCodeTypes.used.name
                                ? ColorManager.primary
                                : widget.type == PromoCodeTypes.used.name
                                    ? ColorManager.darkGrey
                                    : ColorManager.red,
                          ),
                        ),
                        if (discountInfo['showSvg'] == true)
                          SvgPicture.asset(
                            AssetsManager.saudiRiyalSymbol,
                            height: 16.h,
                            width: 16.w,
                            color: widget.type == PromoCodeTypes.active.name ||
                                    widget.type == PromoCodeTypes.used.name
                                ? ColorManager.primary
                                : widget.type == PromoCodeTypes.used.name
                                    ? ColorManager.darkGrey
                                    : ColorManager.red,
                          ),
                        if (discountInfo['type'] != 'none')
                          Text(
                            " ${translate(AppStrings.promoTitle)}",
                            style: AppStyles.body14Medium
                                .copyWith(color: ColorManager.black),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.type == PromoCodeTypes.active.name ||
                  widget.type == PromoCodeTypes.used.name)
                ButtonUsePromoCode(
                  promoCodeModel: widget.promoCodeModel,
                ),
            ],
          ),
          10.ph,
          // Display number of uses
          if (widget.promoCodeModel.numberOfUses != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: widget.type == PromoCodeTypes.active.name
                    ? ColorManager.primary.withOpacity(0.1)
                    : widget.type == PromoCodeTypes.used.name
                        ? ColorManager.darkGrey.withOpacity(0.1)
                        : ColorManager.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 12.sp,
                    color: widget.type == PromoCodeTypes.active.name
                        ? ColorManager.primary
                        : widget.type == PromoCodeTypes.used.name
                            ? ColorManager.darkGrey
                            : ColorManager.red,
                  ),
                  4.horizontalSpace,
                  Text(
                    "${translate(AppStrings.used)}: ${widget.promoCodeModel.numberOfUses}",
                    style: AppStyles.caption12Regular.copyWith(
                      color: widget.type == PromoCodeTypes.active.name
                          ? ColorManager.primary
                          : widget.type == PromoCodeTypes.used.name
                              ? ColorManager.darkGrey
                              : ColorManager.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            8.ph,
          ],
          if (widget.promoCodeModel.expiryDate != null) ...[
            8.ph,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: widget.type == PromoCodeTypes.active.name
                    ? ColorManager.primary.withOpacity(0.1)
                    : widget.type == PromoCodeTypes.used.name
                        ? ColorManager.darkGrey.withOpacity(0.1)
                        : ColorManager.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 12.sp,
                    color: widget.type == PromoCodeTypes.active.name
                        ? ColorManager.primary
                        : widget.type == PromoCodeTypes.used.name
                            ? ColorManager.darkGrey
                            : ColorManager.red,
                  ),
                  4.horizontalSpace,
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "${translate(AppStrings.validUp)} ${discountInfo['displayText']} ",
                            style: AppStyles.caption12Regular.copyWith(
                              color: widget.type ==
                                          PromoCodeTypes.active.name ||
                                      widget.type == PromoCodeTypes.used.name
                                  ? ColorManager.primary
                                  : widget.type == PromoCodeTypes.used.name ||
                                          widget.type ==
                                              PromoCodeTypes.active.name
                                      ? ColorManager.darkGrey
                                      : ColorManager.red,
                            ),
                          ),
                          if (discountInfo['showSvg'] == true)
                            WidgetSpan(
                              child: SvgPicture.asset(
                                AssetsManager.saudiRiyalSymbol,
                                height: 12.h,
                                width: 12.w,
                                color: widget.type ==
                                            PromoCodeTypes.active.name ||
                                        widget.type == PromoCodeTypes.used.name
                                    ? ColorManager.primary
                                    : widget.type == PromoCodeTypes.used.name
                                        ? ColorManager.darkGrey
                                        : ColorManager.red,
                              ),
                            ),
                          TextSpan(
                            text: widget.type == PromoCodeTypes.active.name
                                ? " ${translate(AppStrings.expiresDate)} ${widget.promoCodeModel.expiryDate!}"
                                : widget.type == PromoCodeTypes.used.name
                                    ? " ${widget.promoCodeModel.expiryDate!}"
                                    : " ${translate(AppStrings.expiresDate)} ${widget.promoCodeModel.expiryDate!}",
                            style: AppStyles.caption12Regular.copyWith(
                              color: widget.type ==
                                          PromoCodeTypes.active.name ||
                                      widget.type == PromoCodeTypes.used.name
                                  ? ColorManager.primary
                                  : widget.type == PromoCodeTypes.used.name ||
                                          widget.type ==
                                              PromoCodeTypes.active.name
                                      ? ColorManager.darkGrey
                                      : ColorManager.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
