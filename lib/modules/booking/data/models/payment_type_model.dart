import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

class PaymentMethodModel {
  final String image;
  final String title;
  final int value;
  PaymentMethodModel({
    required this.image,
    required this.value,
    required this.title,
  });

  static List<PaymentMethodModel> listPaymentMethods = <PaymentMethodModel>[
    PaymentMethodModel(
      image: AssetsManager.creditCard,
      title: translate(AppStrings.creditCards),
      value: 1,
    ),
    PaymentMethodModel(
      image: "assets/svg/apple-logo-svgrepo-com.svg",
      title: translate(AppStrings.applePay),
      value: 3,
    ),
    PaymentMethodModel(
      image: AssetsManager.wallet,
      title: translate(AppStrings.wallet),
      value: 2,
    ),
  ];
}
