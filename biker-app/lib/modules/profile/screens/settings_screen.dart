import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/design/components/k_theme_picker.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/profile/widget/profile/drop_down_language.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        title: Text(
          tr(context, AppStrings.settings),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(KSpace.l),
        child: Column(
          children: <Widget>[
            DropDownLanguage(),
            SizedBox(height: KSpace.xl),
            KThemePicker(),
          ],
        ),
      ),
    );
  }
}
