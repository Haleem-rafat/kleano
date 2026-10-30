import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/profile/blocs/update_profile/update_profile_bloc.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/utilties/navigator.dart';

class DropDownLanguage extends StatefulWidget {
  const DropDownLanguage({super.key});

  @override
  State<DropDownLanguage> createState() => _DropDownLanguageState();
}

class _DropDownLanguageState extends State<DropDownLanguage> {
  late String dropdownvalue;
  final languageController = TextEditingController();
  List<String> items = <String>[
    AppConstants.english,
    AppConstants.arabic,
  ];

  @override
  void initState() {
    super.initState();
    dropdownvalue =
        AppShared.lang == 'en' ? AppConstants.english : AppConstants.arabic;
  }

  @override
  void dispose() {
    languageController.dispose();
    super.dispose();
  }

  void _changeLocale(String locale) {
    setState(() {
      changeLocale(context, locale);
      // Set dropdownvalue to the display name, not the locale code
      dropdownvalue =
          locale == 'en' ? AppConstants.english : AppConstants.arabic;
      AppShared.lang = locale;
    });
  }

  void _updateUserLanguage(String val) {
    if (val == AppConstants.english) {
      _changeLocale('en');
    } else if (val == AppConstants.arabic) {
      _changeLocale('ar');
    }
    BlocProvider.of<UpdateProfileBloc>(context)
        .add(UpdateUserLanguage(languageCode: AppShared.lang));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateProfileBloc, UpdateProfileState>(
      listener: (context, state) {
        if (state is ChangeUserLanguageSuccess) {
          popALlAndPushPage(context, MainNavigationScreen(selectedIndex: 4));
        } else if (state is ChangeUserLanguageFailed) {
          showSnackBar(
              buildContext: context,
              message: Localizations.localeOf(context).languageCode == 'ar'
                  ? state.errorModel!.ar!
                  : state.errorModel!.en!);
        }
      },
      child: Container(
        height: 56.h,
        width: 328.w,
        decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: ColorManager.black.withValues(alpha: .05),
                blurRadius: 3.r,
                offset: const Offset(0, 3),
              ),
            ]),
        child: CustomDropdown(
          hintText: dropdownvalue,
          items: items,
          decoration: CustomDropdownDecoration(
            hintStyle: AppStyles.titleGray16Regular,
            listItemStyle: AppStyles.title16Regular.copyWith(
              color: ColorManager.darkGrey,
            ),
          ),
          excludeSelected: true,
          onChanged: (val) {
            _updateUserLanguage(val!);
          },
        ),
      ),
    );
  }
}
