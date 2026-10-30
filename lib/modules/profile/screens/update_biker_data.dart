import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/widget/profile/biker_photo_widget.dart';
import 'package:thewhsherbiker/shared/components/app_bar.dart';
import 'package:thewhsherbiker/shared/components/buttons.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/components/test-screen.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';
import 'package:thewhsherbiker/utilties/validator.dart';

class UpdateBikerData extends StatefulWidget {
  const UpdateBikerData({Key? key}) : super(key: key);

  @override
  State<UpdateBikerData> createState() => _UpdateBikerDataState();
}

class _UpdateBikerDataState extends State<UpdateBikerData> {
  late TextEditingController nameController;
  late final GlobalKey<FormState> _loginFormKey;
  late final ProfileBloc profileBloc;
  File? pick;

  @override
  void initState() {
    super.initState();
    profileBloc = context.read<ProfileBloc>();
    nameController = TextEditingController();
    _loginFormKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> pickImage(bool camera) async {
    final XFile? image;
    try {
      if (camera) {
        image = await ImagePicker().pickImage(
            source: ImageSource.camera,
            maxHeight: 200,
            maxWidth: 200,
            imageQuality: 20);
      } else {
        image = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            maxHeight: 200,
            maxWidth: 200,
            imageQuality: 20);
      }

      if (image == null) return;

      final File imageTemp = File(image.path);

      setState(() => pick = imageTemp);
    } on PlatformException catch (e) {}
  }

  Future<void> _updateBikerInfo() async {
    profileBloc.add(BikerProfileEdit(
      name: nameController.text.isEmpty
          ? profileBloc.profile.userName!
          : nameController.text.trim(),
      image: pick != null ? pick!.path : "",
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: AppBarWhiteShared(
          titleText: translate(AppStrings.modifyPersonalData),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 22.h,
              ),
              BikerPhotoWidget(
                pick: pick,
                onTap: () => showActionSheet(context),
              ),
              SizedBox(
                height: 66.h,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: <Widget>[
                        ListTileTextForm(
                          validator: validatorName,
                          title: translate(AppStrings.name),
                          obscure: false,
                          hintText: profileBloc.profile.userName!,
                          textInputType: TextInputType.name,
                          controller: nameController,
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          Positioned(
            top: 80.h,
            right: 150.w,
            child: SvgPicture.asset(
              ImageAssets.cameraLogo,
              height: 24.h,
              width: 24.w,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildButtonSave(),
    );
  }

  BlocConsumer<ProfileBloc, ProfileState> _buildButtonSave() {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (BuildContext context, ProfileState state) {
        if (state is BikerProfileEditFailed) {
          showSnackBar(
            buildContext: context,
            message: state.error,
          );
        } else if (state is BikerProfileEditSuccess) {
          pop(context);
        }
      },
      builder: (BuildContext context, ProfileState state) {
        if (state is BikerProfileEditLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
            child: SizedBox(
              height: 50.h,
              child: const LoadingWidget(),
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
            child: ButtonsShared(
              onPressed: _updateBikerInfo,
              text: translate(AppStrings.save),
              borderRadius: 8,
              textStyle: AppStyles.title16Bold,
            ),
          );
        }
      },
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
              pickImage(false);
            },
            child: Text(
              translate(AppStrings.chooseFromGallery),
              style: AppStyles.title16Regular
                  .copyWith(color: ColorManager.primary),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              pop(context);
              pickImage(true);
            },
            child: Text(
              translate(AppStrings.takeAPhoto),
              style: AppStyles.title16Regular
                  .copyWith(color: ColorManager.primary),
            ),
          ),
        ],
      ),
    );
  }
}
