import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/components/k_picker_field.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
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
  List<String> items = <String>[AppConstants.english, AppConstants.arabic];

  @override
  void initState() {
    super.initState();
    dropdownvalue = AppShared.lang == 'en'
        ? AppConstants.english
        : AppConstants.arabic;
  }

  void _changeLocale(String locale) {
    setState(() {
      changeLocale(context, locale);
      // Set dropdownvalue to the display name, not the locale code
      dropdownvalue = locale == 'en'
          ? AppConstants.english
          : AppConstants.arabic;
      AppShared.lang = locale;
    });
  }

  void _updateUserLanguage(String val) {
    if (val == AppConstants.english) {
      _changeLocale('en');
    } else if (val == AppConstants.arabic) {
      _changeLocale('ar');
    }
    BlocProvider.of<UpdateProfileBloc>(
      context,
    ).add(UpdateUserLanguage(languageCode: AppShared.lang));
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
                : state.errorModel!.en!,
          );
        }
      },
      child: KPickerField<String>(
        label: translate(AppStrings.language),
        // The current language is not offered, so picking always changes it.
        items: items.where((String item) => item != dropdownvalue).toList(),
        itemLabel: (String item) => item,
        value: dropdownvalue,
        onSelected: _updateUserLanguage,
      ),
    );
  }
}
