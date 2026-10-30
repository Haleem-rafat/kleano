import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/components/circle_image.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';

class BikerPhotoWidget extends StatelessWidget {
  final File? pick;
  final Function() onTap;
  const BikerPhotoWidget({super.key, this.pick, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => onTap(),
      child: Center(
        child: SizedBox(
          height: 84.h,
          width: 84.w,
          child: CircleAvatar(
            backgroundColor: ColorManager.orange,
            child: pick == null
                ? BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (BuildContext context, ProfileState state) {
                      final ProfileBloc profileBloc = context.read<ProfileBloc>();
                      final String? imageUrl = profileBloc.getUserImage();
                      final File? localImageFile = profileBloc.getLocalImageFile();
                      final String bikerName = profileBloc.getUserName();

                      if (imageUrl != null) {
                        return CircleImageShared(
                          imageUrl: imageUrl,
                          radius: 42.r,
                          name: bikerName,
                        );
                      } else if (localImageFile != null) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.file(
                            localImageFile,
                            height: 82.h,
                            width: 82.w,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return Text(
                          bikerName,
                          style: AppStyles.title16Bold.copyWith(
                            color: ColorManager.secondary,
                            fontSize: 30.sp,
                          ),
                        );
                      }
                    },
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.file(
                      pick!,
                      height: 82.h,
                      width: 82.w,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
