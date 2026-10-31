import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class WalletTopupSuccess extends StatefulWidget {
  const WalletTopupSuccess({super.key});

  @override
  State<WalletTopupSuccess> createState() => _WalletTopupSuccessState();
}

class _WalletTopupSuccessState extends State<WalletTopupSuccess> {
  @override
  void initState() {
    // Refresh user profile to update wallet balance
    sl<GetUserProfileBloc>().add(GetUserProfileEvent(isRefresh: true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return KDialog(
      icon: SvgPicture.asset(
        AssetsManager.wallet,
        height: 88,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          KColors.of(context).brand,
          BlendMode.srcIn,
        ),
      ),
      title: translate(AppStrings.paymentSuccessful),
      message: isEnglish
          ? 'Your wallet has been topped up successfully'
          : 'تم شحن محفظتك بنجاح',
      actions: <Widget>[
        KButton(
          label: translate(AppStrings.back),
          onPressed: () {
            Navigator.pop(context); // Close dialog
            popALlAndPushPage(context, MainNavigationScreen(selectedIndex: 4));
          },
        ),
      ],
    );
  }
}
