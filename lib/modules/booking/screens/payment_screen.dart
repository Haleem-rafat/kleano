import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/core/services/apple_pay_service.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/data/models/payment_methods_request.dart';
import 'package:thewasher/modules/booking/widgets/card_form.dart';
import 'package:thewasher/modules/booking/widgets/functions/create_order_data_request.dart';
import 'package:thewasher/modules/booking/widgets/payment_webview.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'dart:io';

class PaymentScreen extends StatefulWidget {
  final String? subscriptionId;
  final bool? isBottomSheet;
  const PaymentScreen({
    super.key,
    this.subscriptionId,
    this.isBottomSheet,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final GlobalKey<FormState> _cardFormKey;
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;
  bool _isLoading = false;
  late final BookingOrderBloc _createOrderBloc;
  GeneralSingleton generalSingleton = GeneralSingleton();

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _createOrderBloc = sl<BookingOrderBloc>();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _setupControllers() {
    _cardFormKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _numberController = TextEditingController();
    _expiryController = TextEditingController();
    _cvvController = TextEditingController();
  }

  void _disposeControllers() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
  }

  void _setLoading(bool value) {
    setState(() => _isLoading = value);
  }

  void _showError(String message) {
    showSnackBar(buildContext: context, message: message);
  }

  Future<void> _submitPayment() async {
    if (_cardFormKey.currentState?.validate() != true) {
      showSnackBar(
        buildContext: context,
        message: Localizations.localeOf(context).languageCode == 'en'
            ? "Complete the other options"
            : "اكمل باقي الخيارات",
      );
      return;
    }

    final bloc = sl<OffersBloc>();
    final expiryParts = _expiryController.text.split('/');
    bloc.cardNumber = _numberController.text.replaceAll(' ', '');
    bloc.expiryMonth = expiryParts[0].trim();
    bloc.cardCvv = _cvvController.text;
    bloc.cardHolderName = _nameController.text;
    bloc.expiryYear = '20${expiryParts[1].trim()}';

    if (widget.subscriptionId != null) {
      // Payment for subscription
      sl<PlansAndSubscriptionBloc>().add(
        PaySubscription(
          subscriptionId: widget.subscriptionId!,
          paymentDetailsRequest: PaymentDetailsRequest(
            name: bloc.cardHolderName,
            number: bloc.cardNumber,
            cvc: bloc.cardCvv,
            month: bloc.expiryMonth,
            year: bloc.expiryYear,
          ),
        ),
      );
    } else {
      // Payment for order
      _setLoading(true);

      try {
        // prepare order
        CreateOrderFunction().createOrderDataRequest();

        // place order after a short delay to ensure orderId is set
        await Future.delayed(const Duration(seconds: 2));

        _createOrderBloc.add(
          PlaceOrder(
            orderId: generalSingleton.orderId ?? "",
            paymentDetailsRequest: PaymentDetailsRequest(
              name: bloc.cardHolderName,
              number: bloc.cardNumber,
              cvc: bloc.cardCvv,
              month: bloc.expiryMonth,
              year: bloc.expiryYear,
            ),
          ),
        );
      } catch (error) {
        _showError('Failed to create order: $error');
      } finally {
        _setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: widget.isBottomSheet == true
            ? null
            : PreferredSize(
                preferredSize: Size(AppSize.s375, 60.h),
                child: AppBarShared(
                  titleAppBar: translate(AppStrings.payment),
                  isTextOnly: false,
                ),
              ),
        body: _isLoading
            ? const Center(child: LoadingWidget())
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardForm(
                        formKey: _cardFormKey,
                        nameController: _nameController,
                        numberController: _numberController,
                        expiryController: _expiryController,
                        cvvController: _cvvController,
                      ),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: widget.subscriptionId != null
            ? BlocConsumer<PlansAndSubscriptionBloc, PlansAndSubscriptionState>(
                listener: (context, payState) {
                  if (payState is PaySubscriptionSuccess) {
                    pop(context);
                    _onPaySubscriptionSuccess(
                        transactionUrl: payState.paymentUrl);
                  }
                },
                builder: (context, payState) {
                  if (payState is PaySubscriptionLoading) {
                    return const LoadingWidget();
                  }
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: ButtonsShared(
                      onPressed: _submitPayment,
                      text: translate(AppStrings.payNow),
                    ),
                  );
                },
              )
            : BlocConsumer<BookingOrderBloc, BookingOrderState>(
                listener: (context, state) {
                  if (state is PlaceOrderSuccess) {
                    pushPage(
                      context,
                      PaymentWebview(
                        transactionUrl: state.paymentUrl!,
                        onPaymentComplete: (status) {
                          if (status == 'Payment success') {
                            AlertHelper.createOrderSuccess(context);
                          } else {
                            pop(context);
                            showSnackBar(
                                buildContext: context,
                                message: 'Payment Failed');
                          }
                        },
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is CreateOrderLoading) {
                    return const LoadingWidget();
                  }
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: ButtonsShared(
                      onPressed: _submitPayment,
                      text: translate(AppStrings.payNow),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _onPaySubscriptionSuccess({String? transactionUrl}) async {
    if (transactionUrl != null) {
      final paymentResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebview(
            transactionUrl: transactionUrl,
            onPaymentComplete: (status) async {
              if (status == 'Payment success') {
                Navigator.pop(context, true);
                AlertHelper.paymentAddCardSuccess(context).then((value) {
                  sl<PlansAndSubscriptionBloc>().add(GetSubscriptionAndPlans(
                    latitude:
                        sl<GetUserProfileBloc>().profile.location!.latitude!,
                    longitude:
                        sl<GetUserProfileBloc>().profile.location!.longitude!,
                    country:
                        sl<GetUserProfileBloc>().profile.location!.country!,
                  ));
                });
              } else {
                pop(context);
                showSnackBar(buildContext: context, message: 'Payment Failed');
              }
            },
          ),
        ),
      );
      if (paymentResult == true) {}
    }
  }
}
