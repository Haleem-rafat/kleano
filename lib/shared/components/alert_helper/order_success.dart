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
import 'package:thewasher/modules/profile/widgets/button_use_promo.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/utilties/order_utils.dart';

class OrderSuccess extends StatefulWidget {
  const OrderSuccess({super.key});

  @override
  State<OrderSuccess> createState() => _OrderSuccessState();
}

class _OrderSuccessState extends State<OrderSuccess> {
  @override
  void initState() {
    sl<GetUserProfileBloc>().add(GetUserProfileEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KDialog(
      icon: SvgPicture.asset(
        AssetsManager.paymentSuccess,
        height: 88,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          KColors.of(context).text,
          BlendMode.srcIn,
        ),
      ),
      title: translate(AppStrings.weAreOnIt),
      message: translate(AppStrings.yourOderConfirmedTakYourOder),
      actions: <Widget>[
        KButton(
          label: translate(AppStrings.goToOrders),
          onPressed: () {
            // Clear all order details after payment completion
            clearAllOrderDetails();
            copiedPromoCode = null;
            popALlAndPushPage(context, MainNavigationScreen(selectedIndex: 2));
          },
        ),
      ],
    );
  }
}
