import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/utilis/card_formatters.dart';
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CardField(
            label: translate(AppStrings.cardName),
            hint: translate(AppStrings.cardName),
            keyboardType: TextInputType.name,
            controller: nameController,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z. ]')),
              UpperCaseTextFormatter(),
            ],
            validator: CardValidator.validateCardHolderName,
          ),
          const SizedBox(height: KSpace.m),
          CardField(
            label: translate(AppStrings.cardNumber),
            hint: translate(AppStrings.cardNumber),
            keyboardType: TextInputType.number,
            controller: numberController,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberInputFormatter(),
            ],
            validator: CardValidator.validateCardNumber,
          ),
          const SizedBox(height: KSpace.m),
          _buildExpiryAndCVV(),
        ],
      ),
    );
  }

  Widget _buildExpiryAndCVV() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: CardField(
            label: translate(AppStrings.cardExpiryDate),
            hint: 'MM/YY',
            keyboardType: TextInputType.number,
            controller: expiryController,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
              CardMonthInputFormatter(),
            ],
            validator: CardValidator.validateExpiryDate,
          ),
        ),
        const SizedBox(width: KSpace.m),
        Expanded(
          child: CardField(
            label: translate(AppStrings.cvv),
            hint: '***',
            keyboardType: TextInputType.number,
            controller: cvvController,
            obscure: true,
            inputFormatters: <TextInputFormatter>[
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

/// A [KTextField] for card details. What is printed on a card always reads
/// left to right, even in Arabic: otherwise "1234 5678" shows its groups in
/// reverse. The label stays on the reading side.
class CardField extends StatelessWidget {
  const CardField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.prefix,
    this.obscure = false,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    return Directionality(
      textDirection: TextDirection.ltr,
      // The field's own Text widgets (the label) take their alignment from
      // here; the input does not.
      child: DefaultTextStyle.merge(
        textAlign: rtl ? TextAlign.right : TextAlign.left,
        child: KTextField(
          label: label,
          hint: hint,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          prefix: prefix,
          obscure: obscure,
        ),
      ),
    );
  }
}
