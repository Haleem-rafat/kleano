import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/services/apple_pay_service.dart';
import 'package:thewasher/modules/booking/data/models/payment_type_model.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/widgets/button_use_promo.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/booking/widgets/card_payment_type.dart';
import 'package:thewasher/modules/booking/screens/payment_screen.dart';
import 'dart:io';

String? paymentTypeString;

class SelectPaymentTypeScreen extends StatefulWidget {
  final String? planId;
  final num? amount;
  final String? createdAt;

  const SelectPaymentTypeScreen({
    this.amount,
    this.createdAt,
    super.key,
    this.planId,
  });

  @override
  State<SelectPaymentTypeScreen> createState() =>
      _SelectPaymentTypeScreenState();
}

class _SelectPaymentTypeScreenState extends State<SelectPaymentTypeScreen> {
  GeneralSingleton generalSingleton = GeneralSingleton();

  final TextEditingController _promoCode = TextEditingController();

  @override
  void initState() {
    super.initState();
    _promoCode.text = copiedPromoCode?.promoCode ?? '';
  }

  void _onSubscriptionState(
    BuildContext context,
    PlansAndSubscriptionState state,
  ) {
    if (state is CreateSubscriptionFailed) {
      pop(context);
      showSnackBar(
        buildContext: context,
        message: Localizations.localeOf(context).languageCode == 'ar'
            ? state.errorModel!.ar!
            : state.errorModel!.en!,
      );
    } else if (state is CreateSubscriptionSuccess) {
      if (paymentTypeString == 'CREDIT') {
        debugPrint('^^^^^^^${state.subscriptionId}');
        pop(context);
        pushPage(context, PaymentScreen(subscriptionId: state.subscriptionId));
      } else if (paymentTypeString == 'APPLE_PAY') {
        if (Platform.isIOS) {
          debugPrint('^^^^^^^${state.subscriptionId}');
          ApplePayService.showApplePayBottomSheetForSubscription(
            context: context,
            subscriptionId: state.subscriptionId ?? '',
            amount: widget.amount ?? 0,
            createdAt: widget.createdAt ?? DateTime.now().toIso8601String(),
            onPaymentSuccess: (paymentId) {
              pop(context);
              AlertHelper.paymentAddCardSuccess(context);
            },
            onPaymentError: (error) {
              pop(context);
              showSnackBar(buildContext: context, message: error);
            },
          );
        }
      } else if (paymentTypeString == 'WALLET') {
        // Call pay-subscription with just the subscription ID
        if (state.subscriptionId != null && state.subscriptionId!.isNotEmpty) {
          sl<PlansAndSubscriptionBloc>().add(
            PaySubscription(subscriptionId: state.subscriptionId!),
          );
        }
      }
    } else if (state is PaySubscriptionFailed) {
      pop(context);
      showSnackBar(
        buildContext: context,
        message: Localizations.localeOf(context).languageCode == 'ar'
            ? state.errorModel?.ar ?? state.error ?? 'Payment failed'
            : state.errorModel?.en ?? state.error ?? 'Payment failed',
      );
    } else if (state is PaySubscriptionSuccess) {
      // Wallet payment successful
      if (paymentTypeString == 'WALLET') {
        pop(context);
        AlertHelper.paymentAddCardSuccess(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    int? paymentType;
    List<PaymentMethodModel> paymentMethods =
        PaymentMethodModel.listPaymentMethods;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(translate(AppStrings.payment)),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          KSpace.xl,
          KSpace.l,
          KSpace.xl,
          KSpace.l,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: KSpace.xs,
                            bottom: KSpace.s,
                          ),
                          child: Text(
                            translate(AppStrings.choosePaymentMethod),
                            style: KType.headline.copyWith(color: c.text),
                          ),
                        ),
                        KCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: <Widget>[
                              for (
                                int i = 0;
                                i < paymentMethods.length;
                                i++
                              ) ...<Widget>[
                                if (i > 0)
                                  Divider(
                                    height: 1,
                                    indent: CardPaymentMethod.dividerIndent,
                                    color: c.separator,
                                  ),
                                Builder(
                                  builder: (context) {
                                    final PaymentMethodModel type =
                                        paymentMethods[i];
                                    final bool isWalletLocked =
                                        type.value == 2 &&
                                        widget.amount != null &&
                                        (walletBalance ?? 0) < widget.amount!;

                                    return CardPaymentMethod(
                                      walletBalance: walletBalance ?? 0,
                                      isWallet: type.value == 2,
                                      type: type,
                                      groupValue: paymentType ?? -1,
                                      onTap: () {
                                        if (type.value == 2 && isWalletLocked) {
                                          showSnackBar(
                                            buildContext: context,
                                            message:
                                                '${translate(AppStrings.yourWalletBalanceIsNotValid)}. Required: ${widget.amount!.toStringAsFixed(2)}',
                                          );
                                          return;
                                        }

                                        setState(() {
                                          paymentType = type.value;
                                        });

                                        if (type.value == 3 && Platform.isIOS) {
                                          // Apple Pay will be handled in the checkout button
                                        } else if (type.value == 3 &&
                                            !Platform.isIOS) {
                                          showSnackBar(
                                            buildContext: context,
                                            message:
                                                "Apple Pay is only available on iOS",
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.planId != null && paymentType != null)
                  Padding(
                    padding: const EdgeInsets.only(top: KSpace.m),
                    child:
                        BlocConsumer<
                          PlansAndSubscriptionBloc,
                          PlansAndSubscriptionState
                        >(
                          listener: _onSubscriptionState,
                          builder: (context, state) {
                            final bool loading =
                                state is CreateSubscriptionLoading ||
                                state is PaySubscriptionLoading;
                            return KButton(
                              loading: loading,
                              onPressed: loading
                                  ? null
                                  : () {
                                      // Validate wallet balance before proceeding
                                      if (paymentType == 2) {
                                        if (widget.amount != null &&
                                            (walletBalance ?? 0) <
                                                widget.amount!) {
                                          showSnackBar(
                                            buildContext: context,
                                            message:
                                                '${translate(AppStrings.yourWalletBalanceIsNotValid)}. Required: ${widget.amount!.toStringAsFixed(2)}',
                                          );
                                          return;
                                        }
                                      }

                                      // Validate Apple Pay platform
                                      if (paymentType == 3 && !Platform.isIOS) {
                                        showSnackBar(
                                          buildContext: context,
                                          message:
                                              "Apple Pay is only available on iOS",
                                        );
                                        return;
                                      }

                                      switch (paymentType) {
                                        case 1:
                                          paymentTypeString = 'CREDIT';
                                          break;
                                        case 2:
                                          paymentTypeString = 'WALLET';
                                          break;
                                        case 3:
                                          paymentTypeString = 'APPLE_PAY';
                                          break;
                                        default:
                                          paymentTypeString = 'CREDIT';
                                      }

                                      debugPrint("Plan ID: ${widget.planId}");
                                      debugPrint(
                                        "Payment Type: $paymentTypeString",
                                      );
                                      sl<PlansAndSubscriptionBloc>().add(
                                        CreateUserSubscription(
                                          planId: widget.planId ?? '',
                                          paymentType: paymentTypeString!,
                                        ),
                                      );
                                    },
                              label: translate('checkout'),
                            );
                          },
                        ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
