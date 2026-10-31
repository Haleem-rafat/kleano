import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:moyasar/moyasar.dart';
import 'package:thewasher/core/config/api_keys.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_sheet.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/services/apple_pay_service.dart';
import 'package:thewasher/modules/booking/widgets/card_form.dart';
import 'package:thewasher/modules/booking/widgets/payment_webview.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/data/repo/profile_repo.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class WalletTopupScreen extends StatefulWidget {
  const WalletTopupScreen({super.key});

  @override
  State<WalletTopupScreen> createState() => _WalletTopupScreenState();
}

class _WalletTopupScreenState extends State<WalletTopupScreen> {
  final GlobalKey<FormState> _amountFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _cardFormKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _isLoading = false;
  int _selectedPaymentMethod = 1; // 1 = Card, 2 = Apple Pay

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return translate(AppStrings.required);
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    if (amount < 1) {
      return 'Minimum amount is 1 SAR';
    }
    return null;
  }

  Future<void> _submitCardPayment() async {
    if (_amountFormKey.currentState?.validate() != true) {
      return;
    }

    if (_cardFormKey.currentState?.validate() != true) {
      showSnackBar(
        buildContext: context,
        message: Localizations.localeOf(context).languageCode == 'en'
            ? "Please complete all card details"
            : "يرجى إكمال جميع تفاصيل البطاقة",
      );
      return;
    }

    final Color errorColor = KColors.of(context).error;
    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final expiryParts = _expiryController.text.split('/');
      final expiryMonth = expiryParts[0].trim();
      final expiryYear = '20${expiryParts[1].trim()}';

      final paymentDetails = {
        'name': _nameController.text,
        'number': _numberController.text.replaceAll(' ', ''),
        'cvc': _cvvController.text,
        'month': expiryMonth,
        'year': expiryYear,
      };

      final response = await ProfileRepo.topupWallet(
        amount: amount,
        paymentDetails: paymentDetails,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response.success &&
            response.result != null &&
            response.result!.isNotEmpty) {
          final paymentUrl = response.result!;

          // Close the screen first
          Navigator.pop(context);

          // Open payment webview after screen is closed
          await Future.delayed(const Duration(milliseconds: 100));

          if (!mounted) return;

          // Open payment webview
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (webviewContext) => PaymentWebview(
                transactionUrl: paymentUrl,
                onPaymentComplete: (status) {
                  if (status == 'Payment success') {
                    // Close the webview first
                    Navigator.pop(webviewContext);

                    // Show success dialog
                    if (webviewContext.mounted) {
                      AlertHelper.walletTopupSuccess(webviewContext);
                    }
                  } else {
                    // Close the webview on error
                    Navigator.pop(webviewContext);

                    // Show error message
                    showSnackBar(
                      buildContext: webviewContext,
                      message:
                          Localizations.localeOf(webviewContext).languageCode ==
                              'en'
                          ? "Payment failed. Please try again"
                          : "فشل الدفع. الرجاء المحاولة مرة أخرى",
                      backgroundColor: errorColor,
                    );
                  }
                },
              ),
            ),
          );
        } else {
          showSnackBar(
            buildContext: context,
            message: Localizations.localeOf(context).languageCode == 'en'
                ? response.message.isNotEmpty
                      ? response.message
                      : "Failed to top up wallet. Please try again"
                : "فشل شحن المحفظة. الرجاء المحاولة مرة أخرى",
            backgroundColor: errorColor,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showSnackBar(
          buildContext: context,
          message: Localizations.localeOf(context).languageCode == 'en'
              ? "An error occurred. Please try again"
              : "حدث خطأ. الرجاء المحاولة مرة أخرى",
          backgroundColor: errorColor,
        );
      }
    }
  }

  void _handleApplePayResult(dynamic result) async {
    if (result is UnprocessableTokenError) {
      if (mounted) {
        Navigator.pop(context); // Close Apple Pay bottom sheet
        showSnackBar(
          buildContext: context,
          message: result.message,
          backgroundColor: KColors.of(context).error,
        );
      }
    } else if (result is PaymentResponse) {
      // Apple Pay success - show success dialog directly
      if (!mounted) return;

      Navigator.pop(context); // Close Apple Pay bottom sheet

      // Close wallet topup screen
      Navigator.pop(context);

      // Show success dialog
      if (mounted) {
        AlertHelper.walletTopupSuccess(context);
      }
    } else {
      if (mounted) {
        Navigator.pop(context); // Close Apple Pay bottom sheet
        showSnackBar(
          buildContext: context,
          message: Localizations.localeOf(context).languageCode == 'en'
              ? "Payment was cancelled"
              : "تم إلغاء الدفع",
        );
      }
    }
  }

  void _processApplePay() {
    if (_amountFormKey.currentState?.validate() != true) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      return;
    }

    final Color errorColor = KColors.of(context).error;
    if (!ApplePayService.isApplePayAvailable) {
      showSnackBar(
        buildContext: context,
        message: Localizations.localeOf(context).languageCode == 'en'
            ? "Apple Pay is not available on this device"
            : "Apple Pay غير متاح على هذا الجهاز",
        backgroundColor: errorColor,
      );
      return;
    }

    final userId = sl<GetUserProfileBloc>().profile.sId ?? "";

    showKSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(top: KSpace.s),
          child: ApplePay(
            config: PaymentConfig(
              metadata: {
                'userId': userId,
                'amount': amount.toString(),
                'type': 'wallet_topup',
              },
              currency: "SAR",
              publishableApiKey: ApiKeys.publishApiKey,
              amount: (amount * 100).toInt(),
              description: 'Wallet Topup - ${amount.toStringAsFixed(2)} SAR',
              applePay: ApplePayConfig(
                saveCard: false,
                merchantId: 'merchant.kleanoDev',
                label: 'KleanO',
                manual: false,
              ),
            ),
            onPaymentResult: _handleApplePayResult,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final bool isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final bool isCard = _selectedPaymentMethod == 1;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: c.background,
        // The form scrolls under the floating button.
        extendBody: true,
        appBar: GlassAppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          leadingWidth: 60,
          leading: GlassBackButton(
            color: c.brand,
            onPressed: () => pop(context),
          ),
          title: Text(
            translate(AppStrings.wallet),
            style: KType.headline.copyWith(color: c.text),
          ),
        ),
        body: _isLoading
            ? const KLoadingState()
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  KSpace.xl,
                  KSpace.l,
                  KSpace.xl,
                  MediaQuery.paddingOf(context).bottom + KSpace.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Form(
                      key: _amountFormKey,
                      child: KTextField(
                        label: isEnglish ? 'Amount (SAR)' : 'المبلغ (ريال)',
                        hint: isEnglish ? 'Enter amount' : 'أدخل المبلغ',
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validateAmount,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        prefix: Padding(
                          padding: const EdgeInsets.all(KSpace.m),
                          child: SvgPicture.asset(
                            AssetsManager.saudiRiyalSymbol,
                            width: KSpace.xl,
                            height: KSpace.xl,
                            colorFilter: ColorFilter.mode(
                              c.textSecondary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: KSpace.xxl),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: KSpace.xs,
                        bottom: KSpace.s,
                      ),
                      child: Text(
                        isEnglish ? 'Payment Method' : 'طريقة الدفع',
                        style: KType.headline.copyWith(color: c.text),
                      ),
                    ),
                    KCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: <Widget>[
                          _methodRow(
                            c,
                            value: 1,
                            title: isEnglish ? 'Credit Card' : 'بطاقة ائتمان',
                            icon: Icons.credit_card_rounded,
                          ),
                          if (ApplePayService.isApplePayAvailable) ...<Widget>[
                            Divider(
                              height: 1,
                              indent: KSpace.l + KSpace.xxl + KSpace.m,
                              color: c.separator,
                            ),
                            _methodRow(
                              c,
                              value: 2,
                              title: 'Apple Pay',
                              icon: Icons.apple,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isCard) ...<Widget>[
                      const SizedBox(height: KSpace.l),
                      CardForm(
                        formKey: _cardFormKey,
                        nameController: _nameController,
                        numberController: _numberController,
                        expiryController: _expiryController,
                        cvvController: _cvvController,
                      ),
                    ],
                  ],
                ),
              ),
        bottomNavigationBar: _isLoading
            ? null
            : SafeArea(
                minimum: const EdgeInsets.fromLTRB(
                  KSpace.xl,
                  KSpace.s,
                  KSpace.xl,
                  KSpace.l,
                ),
                child: KButton(
                  label: isCard
                      ? (isEnglish ? 'Top Up Wallet' : 'شحن المحفظة')
                      : 'Apple Pay',
                  onPressed: isCard ? _submitCardPayment : _processApplePay,
                ),
              ),
      ),
    );
  }

  Widget _methodRow(
    KColors c, {
    required int value,
    required String title,
    required IconData icon,
  }) {
    final bool selected = _selectedPaymentMethod == value;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: KListRow(
        leading: SizedBox.square(
          dimension: KSpace.xxl,
          child: Icon(icon, color: c.textSecondary),
        ),
        title: title,
        trailing: selected ? Icon(Icons.check_rounded, color: c.brand) : null,
        onTap: () => setState(() => _selectedPaymentMethod = value),
      ),
    );
  }
}
