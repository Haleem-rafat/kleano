import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:moyasar/moyasar.dart';
import 'package:thewasher/core/config/api_keys.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/core/services/apple_pay_service.dart';
import 'package:thewasher/modules/booking/widgets/card_form.dart';
import 'package:thewasher/modules/booking/widgets/payment_webview.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/data/repo/profile_repo.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';

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
                      backgroundColor: ColorManager.red,
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
            backgroundColor: ColorManager.red,
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
          backgroundColor: ColorManager.red,
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
          backgroundColor: ColorManager.red,
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

    if (!ApplePayService.isApplePayAvailable) {
      showSnackBar(
        buildContext: context,
        message: Localizations.localeOf(context).languageCode == 'en'
            ? "Apple Pay is not available on this device"
            : "Apple Pay غير متاح على هذا الجهاز",
        backgroundColor: ColorManager.red,
      );
      return;
    }

    final userId = sl<GetUserProfileBloc>().profile.sId ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
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
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: ColorManager.white,
        appBar: PreferredSize(
          preferredSize: Size(AppSize.s375, 60.h),
          child: AppBarShared(
            titleAppBar: translate(AppStrings.wallet),
            isTextOnly: false,
          ),
        ),
        body: _isLoading
            ? const Center(child: LoadingWidget())
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppPadding.p24.w,
                    AppPadding.p24.h,
                    AppPadding.p24.w,
                    AppPadding.p100.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount Input
                      Form(
                        key: _amountFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEnglish ? 'Amount (SAR)' : 'المبلغ (ريال)',
                              style: AppStyles.title16Medium.copyWith(
                                color: ColorManager.black,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: _validateAmount,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              decoration: InputDecoration(
                                hintText:
                                    isEnglish ? 'Enter amount' : 'أدخل المبلغ',
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: SvgPicture.asset(
                                    AssetsManager.saudiRiyalSymbol,
                                    width: 20.w,
                                    height: 20.h,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                      color: ColorManager.medGray
                                          .withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                      color: ColorManager.primary, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                      color: ColorManager.red, width: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Payment Method Selection
                      Text(
                        isEnglish ? 'Payment Method' : 'طريقة الدفع',
                        style: AppStyles.title16Medium.copyWith(
                          color: ColorManager.black,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Card Payment Option
                      GestureDetector(
                        onTap: () => setState(() => _selectedPaymentMethod = 1),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: _selectedPaymentMethod == 1
                                ? ColorManager.primary.withOpacity(0.1)
                                : ColorManager.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: _selectedPaymentMethod == 1
                                  ? ColorManager.primary
                                  : ColorManager.medGray.withOpacity(0.3),
                              width: _selectedPaymentMethod == 1 ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: 1,
                                groupValue: _selectedPaymentMethod,
                                onChanged: (value) => setState(
                                    () => _selectedPaymentMethod = value!),
                                activeColor: ColorManager.primary,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                isEnglish ? 'Credit Card' : 'بطاقة ائتمان',
                                style: AppStyles.title16Regular.copyWith(
                                  color: ColorManager.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Apple Pay Option (if available)
                      if (ApplePayService.isApplePayAvailable)
                        GestureDetector(
                          onTap: () =>
                              setState(() => _selectedPaymentMethod = 2),
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: _selectedPaymentMethod == 2
                                  ? ColorManager.primary.withOpacity(0.1)
                                  : ColorManager.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: _selectedPaymentMethod == 2
                                    ? ColorManager.primary
                                    : ColorManager.medGray.withOpacity(0.3),
                                width: _selectedPaymentMethod == 2 ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Radio<int>(
                                  value: 2,
                                  groupValue: _selectedPaymentMethod,
                                  onChanged: (value) => setState(
                                      () => _selectedPaymentMethod = value!),
                                  activeColor: ColorManager.primary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Apple Pay',
                                  style: AppStyles.title16Regular.copyWith(
                                    color: ColorManager.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 24.h),

                      // Card Form (shown when card payment is selected)
                      if (_selectedPaymentMethod == 1) ...[
                        CardForm(
                          formKey: _cardFormKey,
                          nameController: _nameController,
                          numberController: _numberController,
                          expiryController: _expiryController,
                          cvvController: _cvvController,
                        ),
                      ],

                      // Submit Button (shown in body for Apple Pay, or at bottom for Card)
                      if (_selectedPaymentMethod == 2) ...[
                        SizedBox(height: 24.h),
                        if (_isLoading)
                          const Center(child: LoadingWidget())
                        else
                          ButtonsShared(
                            onPressed: _processApplePay,
                            text: 'Apple Pay',
                            width: double.infinity,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: _isLoading || _selectedPaymentMethod == 2
            ? const SizedBox.shrink()
            : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.p16.w,
                  vertical: AppPadding.p16.h,
                ),
                child: ButtonsShared(
                  onPressed: _submitCardPayment,
                  text: isEnglish ? 'Top Up Wallet' : 'شحن المحفظة',
                  width: double.infinity,
                ),
              ),
      ),
    );
  }
}
