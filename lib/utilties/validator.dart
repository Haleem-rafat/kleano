import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

String? validatorRequired(String? value) {
  if (value == null || value.trim().isEmpty) {
    return translate(AppStrings.required);
  }
  return null;
}

String? validatorName(String? value) {
  // var  validCharacters = RegExp("/[-._!"`'#%&,:;<>=@{}~\$\(\)\*\+\/\\\?\[\]\^\|]+/");
  if (value == null || value.trim().isEmpty) {
    return translate(AppStrings.requiredName);
  } else if (value.trim().contains(RegExp(r'[!@#$%^&*(),.؟؛?":{}|<>0-9،]'))) {
    return translate(AppStrings.containAlphabet);
  } else if (value.trim().length < 3) {
    return translate(AppStrings.nameContain);
  }
  return null;
}

String? validatorPassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return translate(AppStrings.requiredPassword);
  } else if (value.trim().length < 6) {
    return translate(AppStrings.passwordContain);
  }
  return null;
}

String? validatorPhone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return translate(AppStrings.requiredPhoneNumber);
  } else if (value.trim().length < 9) {
    return translate(AppStrings.phoneNumberContain);
  }
  return null;
}

String? validatorCardNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "required Card Number";
  } else if (value.trim().length < 19) {
    return "Card Number should contain at least 16 number";
  }
  return null;
}

String? validatorEndDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "required Expiry date";
  } else if (value.trim().length < 5) {
    return "please enter Expiry date";
  }
  return null;
}

String? validatorCVVNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "required CVV Number";
  } else if (value.trim().length < 3) {
    return "please enter CVV Number";
  }
  return null;
}

String? validatorEmail(String? value) {
  const String pattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

  final RegExp regExp = RegExp(pattern);
  if (value == null || value.isEmpty) {
    return null;
  } else if (!regExp.hasMatch(value)) {
    return translate("notValidEmail");
  }
  return null;
}

String? isPasswordValid(String? password) {
  if (!password!.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>=\-_]'))) {
    return "Password should not contain special characters";
  }
  return null;
}
