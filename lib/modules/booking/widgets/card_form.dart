import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/utilis/card_formatters.dart';
import 'package:thewasher/shared/components/list_tile_text_form.dart';
import 'package:thewasher/core/utilis/card_validation.dart';

class CardForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController numberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;

  const CardForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.numberController,
    required this.expiryController,
    required this.cvvController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          8.verticalSpace,
          ListTileTextForm(
            title: translate(AppStrings.cardName),
            hintText: translate(AppStrings.cardName),
            textInputType: TextInputType.name,
            controller: nameController,
            textInputFormatter: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z. ]')),
              UpperCaseTextFormatter(),
            ],
            validator: CardValidator.validateCardHolderName,
          ),
          8.verticalSpace,
          ListTileTextForm(
            title: translate(AppStrings.cardNumber),
            hintText: translate(AppStrings.cardNumber),
            textInputType: TextInputType.number,
            controller: numberController,
            textInputFormatter: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberInputFormatter(),
            ],
            validator: CardValidator.validateCardNumber,
          ),
          8.verticalSpace,
          _buildExpiryAndCVV(),
        ],
      ),
    );
  }

  Widget _buildExpiryAndCVV() {
    return Row(
      children: [
        Expanded(
          child: ListTileTextForm(
            title: translate(AppStrings.cardExpiryDate),
            hintText: 'MM/YY',
            textInputType: TextInputType.number,
            controller: expiryController,
            textInputFormatter: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
              CardMonthInputFormatter(),
            ],
            validator: CardValidator.validateExpiryDate,
          ),
        ),
        16.horizontalSpace,
        Expanded(
          child: ListTileTextForm(
            title: translate(AppStrings.cvv),
            hintText: '***',
            textInputType: TextInputType.number,
            controller: cvvController,
            isPassword: true,
            textInputFormatter: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            validator: CardValidator.validateCVC,
          ),
        ),
      ],
    );
  }
}
