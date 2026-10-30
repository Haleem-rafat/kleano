import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

class HeaderProfileWidget extends StatefulWidget {
  final Profile userProfile;
  final bool? comeAnotherScreen;
  const HeaderProfileWidget({
    super.key,
    required this.userProfile,
    this.comeAnotherScreen = false,
  });

  @override
  State<HeaderProfileWidget> createState() => _HeaderProfileWidgetState();
}

class _HeaderProfileWidgetState extends State<HeaderProfileWidget> {
  late String name;
  late String image;
  late String characterUserName;
  @override
  void initState() {
    super.initState();
    name = widget.userProfile.userName!;
    image = widget.userProfile.imageLink != null
        ? widget.userProfile.imageLink!
        : 'null';
    characterUserName = image != 'null'
        ? widget.userProfile.imageLink!
        : widget.userProfile.userName!.split('').first;
    GeneralSingleton().characterUserName = characterUserName;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 201.h,
        width: 1.sw,
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Container(
              height: 110.h,
              width: 1.sw,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: ColorManager.black.withValues(alpha: .05),
                      blurRadius: 3.r,
                      offset: const Offset(0, 6))
                ],
                color: ColorManager.primary,
              ),
            ),
            if (widget.comeAnotherScreen!)
              Positioned(
                top: 50.h,
                left: 20.w,
                child: GestureDetector(
                  onTap: () => pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: ColorManager.white,
                    size: AppSize.s24,
                  ),
                ),
              ),
            Positioned(
              bottom: 55.h,
              left: 150.w,
              right: 150.w,
              child: SizedBox(
                height: 73.25.h,
                width: 73.25.w,
                child: CircleAvatar(
                  backgroundColor: ColorManager.primaryLight2,
                  child: image != 'null'
                      ? ImageShared(
                          image: image,
                          height: 73.25.h,
                          width: 73.25.w,
                          raduis: 50,
                        )
                      : Text(
                          characterUserName,
                          style: AppStyles.title16Bold.copyWith(
                            color: ColorManager.secondary,
                            fontSize: 30.sp,
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              bottom: 25.h,
              left: 0.w,
              right: 0.w,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: AppStyles.title16Bold.copyWith(
                  color: ColorManager.black,
                ),
              ),
            )
          ],
        ));
  }
}
