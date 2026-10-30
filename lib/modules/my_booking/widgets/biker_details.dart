import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/tracking_order/data/models/accepted_biker_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class BikerDetails extends StatelessWidget {
  final Biker biker;
  final Location location;
  const BikerDetails({
    super.key,
    required this.biker,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header with Icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.person,
                  color: ColorManager.primary,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                translate(AppStrings.biker),
                style: AppStyles.title16Bold.copyWith(
                  color: ColorManager.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Biker Info Row
          Row(
            children: <Widget>[
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorManager.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: ColorManager.primary.withValues(alpha: 0.2),
                  //     blurRadius: 8,
                  //     offset: const Offset(0, 2),
                  //   ),
                  // ],
                ),
                child: CircleAvatar(
                  backgroundColor: ColorManager.primaryLight,
                  radius: 28.r,
                  child: biker.imageLink != null && biker.imageLink!.isNotEmpty
                      ? ClipOval(
                          child: ImageShared(
                            image: biker.imageLink!,
                            height: 56.h,
                            width: 56.w,
                            raduis: 50,
                          ),
                        )
                      : Text(
                          biker.userName != null && biker.userName!.isNotEmpty
                              ? biker.userName!
                                  .split(' ')
                                  .first[0]
                                  .toUpperCase()
                              : 'B',
                          style: AppStyles.title16Bold.copyWith(
                            color: ColorManager.primary,
                            fontSize: 20.sp,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 16.w),
              // Name and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      biker.userName ?? 'Unknown',
                      style: AppStyles.title16Bold.copyWith(
                        color: ColorManager.black,
                        fontSize: 16.sp,
                      ),
                    ),
                    // if (biker.rating != null && biker.rating! > 0) ...[
                    //   SizedBox(height: 8.h),
                    //   Row(
                    //     children: [
                    //       Text(
                    //         biker.rating!.toStringAsFixed(1),
                    //         style: AppStyles.body14Medium.copyWith(
                    //           color: ColorManager.black,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //       SizedBox(width: 6.w),
                    //       ...List.generate(
                    //         biker.rating!.toInt().clamp(0, 5),
                    //         (index) => Padding(
                    //           padding: EdgeInsets.only(right: 2.w),
                    //           child: SvgPicture.asset(
                    //             AssetsManager.starSelected,
                    //             height: 14.h,
                    //             width: 14.w,
                    //           ),
                    //         ),
                    //       ),
                    //       ...List.generate(
                    //         (5 - biker.rating!.toInt().clamp(0, 5)).clamp(0, 5),
                    //         (index) => Padding(
                    //           padding: EdgeInsets.only(right: 2.w),
                    //           child: SvgPicture.asset(
                    //             AssetsManager.starUnselected,
                    //             height: 14.h,
                    //             width: 14.w,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ],
                  ],
                ),
              ),
            ],
          ),
          // Phone Number if available
          if (biker.phone != null && biker.phone!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: ColorManager.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: ColorManager.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.phone,
                      color: ColorManager.primary,
                      size: 18.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate(AppStrings.phoneNumber),
                          style: AppStyles.caption12Medium.copyWith(
                            color: ColorManager.medGray,
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          biker.phone!,
                          style: AppStyles.subtext14Regular.copyWith(
                            color: ColorManager.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Call and WhatsApp Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    onTap: () => _callBiker(biker.phone!),
                    icon: Icons.phone,
                    label: translate(AppStrings.call),
                    color: ColorManager.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildActionButton(
                    onTap: () => _openWhatsApp(biker.phone!),
                    icon: Icons.chat,
                    label: translate(AppStrings.whatsapp),
                    color: const Color(0xFF25D366),
                    isWhatsApp: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _callBiker(String phoneNumber) async {
    final String phone = phoneNumber.replaceAll('+', '').trim();

    try {
      if (Platform.isAndroid) {
        await FlutterPhoneDirectCaller.callNumber(phone);
      } else if (Platform.isIOS) {
        final Uri telUri = Uri(scheme: 'tel', path: phone);
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        } else {
          throw 'Could not launch dialer';
        }
      }
    } catch (e) {
      debugPrint('Error calling biker: $e');
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    try {
      final String phone =
          phoneNumber.replaceAll('+', '').replaceAll(' ', '').trim();

      // Ensure the phone number starts with country code
      String whatsappNumber = phone.startsWith('966') ? phone : '966$phone';

      final Uri whatsappUri = Uri.parse('https://wa.me/$whatsappNumber');

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      debugPrint('Error opening WhatsApp: $e');
    }
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
    bool isWhatsApp = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: color.withValues(alpha: 0.1),
          //     blurRadius: 8,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isWhatsApp)
              SvgPicture.asset(
                AssetsManager.whatsappIcon,
                height: 20.h,
                width: 20.w,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            else
              Icon(
                icon,
                color: color,
                size: 20.w,
              ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppStyles.subtext14Regular.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
