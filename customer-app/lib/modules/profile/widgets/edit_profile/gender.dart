import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/profile/blocs/update_profile/update_profile_bloc.dart';
import 'package:thewasher/shared/singleton.dart';

class SelectGender extends StatefulWidget {
  final bool isEdit;
  final String gender;
  const SelectGender({super.key, required this.isEdit, required this.gender});

  @override
  State<SelectGender> createState() => _SelectGenderState();
}

class _SelectGenderState extends State<SelectGender> {
  late UpdateProfileBloc updateProfileBloc = UpdateProfileBloc();
  late List<String> genderType;
  late String gender;
  late GeneralSingleton generalSingleton;
  final genderController = TextEditingController();
  @override
  void initState() {
    super.initState();
    updateProfileBloc = UpdateProfileBloc();
    genderType = ['Male', 'Female'];
    gender = widget.gender.isNotEmpty
        ? widget.gender
        : generalSingleton.gender != null
        ? generalSingleton.gender!
        : '---';
    generalSingleton = GeneralSingleton();
  }

  @override
  void dispose() {
    genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 19.w),
          child: Text(
            translate(AppStrings.gender),
            style: AppStyles.titleGray16Regular.copyWith(
              color: ColorManager.darkGrey,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: AppPadding.p25.h),
          child: !widget.isEdit
              ? widget.gender.isEmpty
                    ? DottedLine(
                        lineLength: 40.w,
                        dashColor: ColorManager.medGray,
                        dashGapLength: 2.0,
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 19.w),
                        child: Text(
                          widget.gender,
                          style: AppStyles.titleGray16Regular,
                        ),
                      )
              : CustomDropdown(
                  hintText: widget.gender.isNotEmpty ? widget.gender : '----',
                  items: genderType,
                  excludeSelected: false,
                  disabledDecoration: CustomDropdownDisabledDecoration(
                    border: Border.all(color: ColorManager.medGray),
                  ),
                  decoration: CustomDropdownDecoration(
                    hintStyle: AppStyles.titleGray16Regular,
                    listItemStyle: AppStyles.title16Regular.copyWith(
                      color: ColorManager.darkGrey,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      generalSingleton.gender = val;
                      updateProfileBloc.gender = val;
                      gender = val!;
                    });
                  },
                ),
        ),
      ],
    );
  }
}
