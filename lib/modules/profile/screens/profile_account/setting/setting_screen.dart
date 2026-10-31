import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_theme_picker.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/widgets/drop_down_language.dart';
import 'package:thewasher/modules/profile/widgets/home_style_picker.dart';
import 'package:thewasher/modules/profile/widgets/toggle_notification.dart';
import 'package:thewasher/utilties/navigator.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: KColors.of(context).background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(
          onPressed: () {
            pop(context);
            context.read<GetUserProfileBloc>().add(
              GetUserProfileEvent(isRefresh: true),
            );
          },
        ),
        title: Text(translate(AppStrings.settings)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(KSpace.xl),
        children: const <Widget>[
          DropDownLanguage(),
          SizedBox(height: KSpace.xl),
          KThemePicker(),
          SizedBox(height: KSpace.xl),
          HomeStylePicker(),
          SizedBox(height: KSpace.xl),
          KCard(padding: EdgeInsets.zero, child: ToggleNotification()),
        ],
      ),
    );
  }
}
