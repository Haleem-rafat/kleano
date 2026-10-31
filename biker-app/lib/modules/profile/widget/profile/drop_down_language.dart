import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/core/design/components/k_picker_field.dart';
import 'package:thewhsherbiker/core/resources/constant_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';

class DropDownLanguage extends StatefulWidget {
  const DropDownLanguage({super.key});

  @override
  State<DropDownLanguage> createState() => _DropDownLanguageState();
}

class _DropDownLanguageState extends State<DropDownLanguage> {
  List<String> items = <String>[AppConstants.english, AppConstants.arabic];

  void _changeLocale(String locale) {
    setState(() {
      changeLocale(context, locale);
      AppShared.lang = locale;
    });
  }

  void _updateUserLanguage(String val) {
    if (val == AppConstants.english) {
      _changeLocale('en');
    } else if (val == AppConstants.arabic) {
      _changeLocale('ar');
    }
    BlocProvider.of<ProfileBloc>(
      context,
    ).add(UpdateBikerLanguage(languageCode: AppShared.lang));
  }

  @override
  Widget build(BuildContext context) {
    final bool arabic = Localizations.localeOf(context).languageCode == 'ar';
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (BuildContext context, Object? state) {
        if (state is ChangeBikerLanguageFailed) {
          showSnackBar(
            buildContext: context,
            message: arabic ? state.errorModel!.ar! : state.errorModel!.en!,
          );
        }
      },
      child: KPickerField<String>(
        label: tr(context, AppStrings.language),
        items: items,
        itemLabel: (String item) => tr(context, item),
        value: tr(context, arabic ? AppConstants.arabic : AppConstants.english),
        onSelected: _updateUserLanguage,
      ),
    );
  }
}
