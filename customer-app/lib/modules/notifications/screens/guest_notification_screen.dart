import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/utilties/navigator.dart';

class GuestNotificationScreen extends StatelessWidget {
  const GuestNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        leadingWidth: 60,
        leading: GlassBackButton(color: c.brand, onPressed: () => pop(context)),
        title: Text(
          translate(AppStrings.notifications),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KSpace.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SvgPicture.asset(AssetsManager.notificationsEmpty),
              const SizedBox(height: KSpace.xxl),
              Text(
                translate(AppStrings.yourNotRegisteredYetJoinUs),
                textAlign: TextAlign.center,
                style: KType.body.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: KSpace.xxl),
              KButton(
                label: translate(AppStrings.signUpNow),
                expand: false,
                onPressed: () =>
                    popALlAndPushPage(context, ChooseRegisterView()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
