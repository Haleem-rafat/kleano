import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/blocs/update_profile/update_profile_bloc.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/modules/profile/data/models/update_profile_request.dart';
import 'package:thewasher/modules/profile/widgets/upload_user_photo.dart';
import 'package:thewasher/shared/components/app_bar.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/components/list_tile_text_form.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/utilties/validator.dart';

class ChangePersonalInformation extends StatefulWidget {
  final Profile user;
  const ChangePersonalInformation({
    super.key,
    required this.user,
  });

  @override
  State<ChangePersonalInformation> createState() =>
      _ChangePersonalInformationState();
}

class _ChangePersonalInformationState extends State<ChangePersonalInformation> {
  late List<Widget> textForms = [];
  late List<String> genderType;
  late GeneralSingleton generalSingleton;
  final genderControllerDropdown = TextEditingController();
  late UpdateProfileBloc updateProfileBloc;
  late String nameText;
  late String emailText;
  late String gender;
  final _signUpFormKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  String? dobText; // Display format (e.g., "Jan 15, 2000")
  String? dobApiFormat; // API format (yyyy-MM-dd)

  @override
  void initState() {
    nameText = widget.user.userName!;
    emailText = widget.user.email ?? "";
    gender = widget.user.gender != null ? widget.user.gender! : '----';

    // Initialize date of birth from user profile
    if (widget.user.dob != null && widget.user.dob!.isNotEmpty) {
      try {
        selectedDate = DateTime.parse(widget.user.dob!);
        // Format for display (e.g., "Jan 15, 2000")
        dobText = DateFormat('MMM dd, yyyy').format(selectedDate!);
        // Keep API format (yyyy-MM-dd)
        dobApiFormat = widget.user.dob;
      } catch (e) {
        selectedDate = null;
        dobText = null;
        dobApiFormat = null;
      }
    }

    genderType = ['Male', 'Female'];
    generalSingleton = GeneralSingleton();
    updateProfileBloc = BlocProvider.of<UpdateProfileBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    genderControllerDropdown.dispose();
    super.dispose();
  }

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 300.h,
          color: ColorManager.white,
          child: Column(
            children: [
              Container(
                height: 50.h,
                color: ColorManager.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(
                        translate(AppStrings.cancel),
                        style: AppStyles.title16Regular.copyWith(
                          color: ColorManager.primary,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: Text(
                        translate(AppStrings.save),
                        style: AppStyles.title16Regular.copyWith(
                          color: ColorManager.primary,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          // Display format for UI
                          dobText = DateFormat('MMM dd, yyyy', 'en')
                              .format(selectedDate!);
                          // API format for backend
                          dobApiFormat = DateFormat('yyyy-MM-dd', 'en')
                              .format(selectedDate!);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: selectedDate ?? DateTime(2000, 1, 1),
                  mode: CupertinoDatePickerMode.date,
                  maximumDate: DateTime.now(),
                  minimumDate: DateTime(1900, 1, 1),
                  onDateTimeChanged: (DateTime newDate) {
                    selectedDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void validationSaveButton() {
    if (widget.user.gender == null || widget.user.gender == '---') {
      if (_signUpFormKey.currentState!.validate()) {
        if (((nameText.trim().isNotEmpty) || (emailText.trim().isNotEmpty)) &&
            (generalSingleton.gender != '---' &&
                    generalSingleton.gender != null ||
                widget.user.gender != null)) {
          generalSingleton.userImage != null
              ? updateProfileBloc.add(UpdateProfileEvent(
                  updateProfileRequest: UpdateProfileRequest(
                  userName: nameText.trim(),
                  email: emailText.trim(),
                  image: File(generalSingleton.userImage!.path),
                  gender: generalSingleton.gender != null
                      ? generalSingleton.gender!
                      : widget.user.gender!,
                  dob: dobApiFormat,
                )))
              : updateProfileBloc.add(UpdateProfileEvent(
                  updateProfileRequest: UpdateProfileRequest(
                  userName: nameText.trim(),
                  email: emailText.trim(),
                  gender: generalSingleton.gender != null
                      ? generalSingleton.gender!
                      : widget.user.gender!,
                  dob: dobApiFormat,
                )));
        }
      }
    } else if (((nameText.trim().isNotEmpty) ||
            (emailText.trim().isNotEmpty)) &&
        (generalSingleton.gender != '---' && generalSingleton.gender != null ||
            widget.user.gender != null)) {
      generalSingleton.userImage != null
          ? updateProfileBloc.add(UpdateProfileEvent(
              updateProfileRequest: UpdateProfileRequest(
              userName: nameText.trim(),
              email: emailText.trim(),
              image: File(generalSingleton.userImage!.path),
              gender: generalSingleton.gender != null
                  ? generalSingleton.gender!
                  : widget.user.gender!,
              dob: dobApiFormat,
            )))
          : updateProfileBloc.add(UpdateProfileEvent(
              updateProfileRequest: UpdateProfileRequest(
              userName: nameText.trim(),
              email: emailText.trim(),
              gender: generalSingleton.gender != null
                  ? generalSingleton.gender!
                  : widget.user.gender!,
              dob: dobApiFormat,
            )));
    }
  }

  @override
  Widget build(BuildContext context) {
    textForms = <Widget>[
      ListTileTextForm(
        initialValue: nameText,
        validator: validatorName,
        title: translate(AppStrings.name),
        hintText: translate(AppStrings.username),
        textInputType: TextInputType.name,
        onChange: (val) {
          setState(() {
            nameText = val;
          });
        },
      ),
      ListTileTextForm(
        initialValue: emailText,
        validator: validatorEmail,
        title: translate(AppStrings.email),
        hintText: "info@kleanoapp.com",
        textInputType: TextInputType.emailAddress,
        onChange: (val) {
          setState(() {
            emailText = val;
          });
        },
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Padding(
          padding: EdgeInsets.only(
              left: AppPadding.p16.w,
              right: AppPadding.p16.w,
              bottom: AppPadding.p8.h),
          child: Text(
            translate(AppStrings.gender),
            style:
                AppStyles.title16Regular.copyWith(color: ColorManager.darkGrey),
          ),
        ),
        subtitle: CustomDropdown(
            hintText: gender,
            items: genderType,
            excludeSelected: false,
            decoration: CustomDropdownDecoration(
              hintStyle: AppStyles.titleGray16Regular,
              listItemStyle: AppStyles.title16Regular.copyWith(
                color: ColorManager.darkGrey,
              ),
            ),
            onChanged: (val) {
              setState(() {
                generalSingleton.gender = val;
              });
            }),
      ),
      // Date of Birth
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Padding(
          padding: EdgeInsets.only(
              left: AppPadding.p16.w,
              right: AppPadding.p16.w,
              bottom: AppPadding.p8.h),
          child: Text(
            translate(AppStrings.dateOfBirth),
            style:
                AppStyles.title16Regular.copyWith(color: ColorManager.darkGrey),
          ),
        ),
        subtitle: GestureDetector(
          onTap: () {
            _showDatePicker(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.p16.w,
              vertical: AppPadding.p16.h,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: ColorManager.lightGray),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dobText ?? 'Select Date of Birth',
                  style: AppStyles.title16Regular.copyWith(
                    color: dobText != null
                        ? ColorManager.darkGrey
                        : ColorManager.medGray,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: ColorManager.primary,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    ];
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: AppBarWhiteShared(
          titleText: translate(AppStrings.changePersonalInformation),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            AppPadding.p10.ph,
            UserPhoto(
              isEdit: true,
              userPhoto: widget.user.imageLink != null
                  ? widget.user.imageLink!
                  : "null",
            ),
            AppPadding.p66.ph,
            Form(
              key: _signUpFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: textForms.map((userForms) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppPadding.p32.h),
                    child: userForms,
                  );
                }).toList(),
              ),
            ),
            AppPadding.p100.ph,
            BlocConsumer<UpdateProfileBloc, UpdateProfileState>(
              listener: (BuildContext context, UpdateProfileState stateUpdate) {
                if (stateUpdate is UpdateProfileFailed) {
                  showSnackBar(
                      buildContext: context,
                      message:
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? stateUpdate.error!.ar!
                              : stateUpdate.error!.en!);
                } else if (stateUpdate is UpdateProfileSuccess) {
                  BlocProvider.of<GetUserProfileBloc>(context)
                      .add(GetUserProfileEvent());
                  pop(context);
                }
              },
              builder: (BuildContext context, UpdateProfileState stateUpdate) {
                if (stateUpdate is UpdateProfileLoading) {
                  return const LoadingWidget();
                }
                return ButtonsShared(
                    onPressed: () {
                      validationSaveButton();
                    },
                    text: translate(AppStrings.save));
              },
            ),
          ]),
        ),
      ),
    );
  }
}
