import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/constant_manager.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';

class DropDownLanguage extends StatefulWidget {
  const DropDownLanguage({super.key});

  @override
  State<DropDownLanguage> createState() => _DropDownLanguageState();
}

class _DropDownLanguageState extends State<DropDownLanguage> {
   String dropdownvalue = '';
  List<String> items = <String>[
    AppConstants.english,
    AppConstants.arabic,
  ];

  void _changeLocale(String locale) {
    setState(() {
      changeLocale(context, locale);
      dropdownvalue = locale;
      AppShared.lang = locale;
    });
  }

  _updateUserLanguage(String val) {
    if (val == AppConstants.english) {
      _changeLocale('en');

    } else if (val == AppConstants.arabic) {
      _changeLocale('ar');
    }
    BlocProvider.of<ProfileBloc>(context).add(UpdateBikerLanguage(languageCode: AppShared.lang));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (BuildContext context, Object? state) {
        if (state is ChangeBikerLanguageSuccess) {
        } else if (state is ChangeBikerLanguageFailed) {
          showSnackBar(
              buildContext: context,
              message: Localizations.localeOf(context).languageCode == 'ar' ? state.errorModel!.ar! : state.errorModel!.en!);
        }
      },
      child: Container(
        width: 328.w,
        decoration: BoxDecoration(color: ColorManager.white, borderRadius: BorderRadius.circular(10.r), boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorManager.black.withOpacity(.05),
            blurRadius: 3.r,
            offset: const Offset(0, 3),
          ),
        ]),
        child: CustomDropdown<String>(
          hintText:  Localizations.localeOf(context).languageCode == 'ar' ? translate(AppConstants.arabic) : translate(AppConstants.english),
          items: items,
          onChanged: (String? val) {
            _updateUserLanguage(val!);
          },
          decoration: CustomDropdownDecoration(
            headerStyle: AppStyles.titleGray16Regular,
            listItemStyle: AppStyles.title16Regular.copyWith(
              color: ColorManager.darkGrey,
            ),
          ),
        ),
      ),
    );
  }
}
