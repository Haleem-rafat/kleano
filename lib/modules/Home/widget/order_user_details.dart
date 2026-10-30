import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thewhsherbiker/core/components/circle_image.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/utilis/enums.dart';
import 'package:thewhsherbiker/core/utilis/launch_map.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderUserDetails extends StatelessWidget {
  const OrderUserDetails({Key? key}) : super(key: key);
  void openWhatsApp(String phoneBiker) async {
    final String phone =
        phoneBiker.replaceAll('+', '').replaceAll(' ', '').trim();

    // Ensure the phone number starts with country code
    String whatsappNumber = phone.startsWith('966') ? phone : '966$phone';

    final Uri whatsappUri = Uri.parse('https://wa.me/$whatsappNumber');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = sl<HomeBloc>().orderDetails;
    return Column(
      children: <Widget>[
        17.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "${order.vehicle?.brand} ${order.vehicle?.model}",
              style: AppStyles.body14Medium.copyWith(
                color: ColorManager.darkGrey,
              ),
            ),
            if (order.status != null)
              Container(
                padding: EdgeInsets.fromLTRB(17.w, 4.h, 17.w, 5.h),
                decoration: BoxDecoration(
                  color: orderStateColor(order.status!),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Text(
                  orderStateName(order.status!),
                  style: AppStyles.caption12Regular
                      .copyWith(color: ColorManager.darkGrey),
                ),
              ),
          ],
        ),
        SizedBox(
          height: 8.h,
        ),
        Row(
          children: <Widget>[
            CircleImageShared(
              imageUrl: order.user?.imageLink ?? '',
              radius: 12.r,
              name: order.user?.userName ?? 'Unknown',
            ),
            SizedBox(
              width: 8.w,
            ),
            if (order.user!.userName != null)
              Text(
                order.user!.userName!,
                style: AppStyles.caption12Medium.copyWith(
                  color: ColorManager.medGray,
                ),
              ),
            Spacer(),
            if (order.user!.phone != null) ...[
              InkWell(
                onTap: () {
                  launchUrl(Uri(
                    scheme: 'tel',
                    path: order.user!.phone,
                  ));
                },
                child: SvgPicture.asset(ImageAssets.phoneLogo),
              ),
              16.horizontalSpace,
              GestureDetector(
                onTap: () => openWhatsApp(order.user!.phone!),
                child: SvgPicture.asset(
                  "assets/svg/whatsapp_icon.svg",
                  height: 22.h,
                  width: 22.w,
                  color: const Color(0xFF25D366),
                ),
              ),
            ]

            // Remove icon chat for now
            // SizedBox(
            //   width: 16.w,
            // ),
            // SvgPicture.asset(ImageAssets.chatLogo),
          ],
        ),
        SizedBox(
          height: 8.h,
        ),
        if (order.location?.streetName != null)
          InkWell(
            onTap: () async {
              await launchMap(
                  lat: order.location?.latitude.toString() ?? "",
                  long: order.location?.longitude.toString() ?? "");
            },
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Row(
              children: <Widget>[
                SvgPicture.asset(ImageAssets.locationIcon),
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: Text(
                      order.location!.streetName!,
                      style: AppStyles.caption12Regular.copyWith(
                        color: ColorManager.medGray,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
