import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

class UserPhoto extends StatefulWidget {
  final bool isEdit;
  final String? userPhoto;
  const UserPhoto({super.key, required this.userPhoto, required this.isEdit});

  @override
  State<UserPhoto> createState() => _UserPhotoState();
}

class _UserPhotoState extends State<UserPhoto> {
  final ImagePicker picker = ImagePicker();
  GeneralSingleton generalSingleton = GeneralSingleton();
  late String userPhoto;
  void getGalleryImage() {
    picker
        .pickImage(
            source: ImageSource.gallery,
            maxHeight: 1000,
            maxWidth: 1000,
            imageQuality: 75)
        .then((XFile? image) {
      setState(() {
        generalSingleton.userImage = image;
        userPhoto = image!.path;
      });
    });
  }

  void getCameraImage() {
    picker
        .pickImage(
            source: ImageSource.camera,
            maxHeight: 1000,
            maxWidth: 1000,
            imageQuality: 75)
        .then((XFile? image) {
      setState(() {
        generalSingleton.userImage = image;
        userPhoto = image!.path;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    userPhoto = widget.userPhoto != "null"
        ? widget.userPhoto!
        : generalSingleton.userImage != null
            ? generalSingleton.userImage!.path
            : generalSingleton.characterUserName!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.isEdit ? showActionSheet(context) : null;
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            SizedBox(
                height: 84.h,
                width: 84.w,
                child:
                    // CircleAvatar(
                    //     backgroundColor: ColorManager.orange,
                    //     child:
                    //     userPhoto.isNotEmpty
                    //         ? userPhoto != generalSingleton.characterUserName
                    //         ? Container(
                    //             height: 84.h,
                    //             width: 84.w,
                    //           decoration: BoxDecoration(
                    //             shape: BoxShape.circle,
                    //             image: DecorationImage(
                    //               image: FileImage(
                    //                 File(generalSingleton.userImage!.path),
                    //                 ),
                    //               fit: BoxFit.cover
                    //               )
                    //           ),
                    //         )
                    //         : ImageShared(
                    //             image: userPhoto,
                    //             height: 84.h,
                    //             width: 84.w,
                    //             raduis: 50,
                    //           )
                    //         : Text(
                    //             generalSingleton.characterUserName!,
                    //             style: AppStyles.title16Bold.copyWith(
                    //               color: ColorManager.secondary,
                    //               fontSize: 30.sp,
                    //             ),
                    //           ),
                    //   ),
                    CircleAvatar(
                  backgroundColor: ColorManager.primaryLight,
                  child: userPhoto != generalSingleton.characterUserName
                      ? Container(
                          height: 84.h,
                          width: 84.w,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: FileImage(
                                    File(generalSingleton.userImage!.path),
                                  ),
                                  fit: BoxFit.cover)),
                        )
                      : userPhoto == widget.userPhoto
                          ? ImageShared(
                              image: userPhoto,
                              height: 84.h,
                              width: 84.w,
                              raduis: 50,
                            )
                          : Text(
                              generalSingleton.characterUserName!,
                              style: AppStyles.title16Bold.copyWith(
                                color: ColorManager.secondary,
                                fontSize: 30.sp,
                              ),
                            ),
                )
                // CircleAvatar(
                //   backgroundColor: ColorManager.orange,
                //   backgroundImage:userPhoto != generalSingleton.characterUserName ? FileImage(File(updateProfileBloc.userImage!.path)) : null,
                //   child: userPhoto == generalSingleton.characterUserName
                //    ? Text(
                //        generalSingleton.characterUserName!,
                //        style: AppStyles.title16Bold.copyWith(
                //          color: ColorManager.secondary,
                //          fontSize: 30.sp,
                //        ),
                //      ): null
                // ),

                ),
            widget.isEdit
                ? SvgPicture.asset(
                    AssetsManager.cameraIcon,
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  void showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          translate(AppStrings.chooseYourPicture),
          style: AppStyles.title16Bold,
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              pop(context);
              getGalleryImage();
            },
            child: Text(
              translate(AppStrings.chooseFromGallery),
              style: AppStyles.title16Regular
                  .copyWith(color: ColorManager.primary),
            ),
          ),
          // CupertinoActionSheetAction(
          //   onPressed: () {
          //     pop(context);
          //     getCameraImage();
          //   },
          //   child: Text(
          //     translate(AppStrings.takeAPhoto),
          //     style: AppStyles.title16Regular
          //         .copyWith(color: ColorManager.primary),
          //   ),
          // ),
        ],
      ),
    );
  }
}
