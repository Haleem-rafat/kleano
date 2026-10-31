import 'package:flutter/services.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Arabic-Indic (٠-٩) and Persian (۰-۹) digits as ASCII 0-9, so a number typed
/// on an Arabic keyboard is not silently dropped.
String toAsciiDigits(String input) {
  final StringBuffer out = StringBuffer();
  for (final int c in input.runes) {
    if (c >= 0x0660 && c <= 0x0669) {
      out.writeCharCode(0x30 + c - 0x0660);
    } else if (c >= 0x06F0 && c <= 0x06F9) {
      out.writeCharCode(0x30 + c - 0x06F0);
    } else {
      out.writeCharCode(c);
    }
  }
  return out.toString();
}

String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

bool _isValid(String international) {
  try {
    return PhoneNumber.parse(international).isValid();
  } catch (_) {
    return false;
  }
}

/// The phone in the one format the backend matches: `+<country><national>`,
/// e.g. `+201202939672`. The backend compares the string exactly, so
/// `+2001202939672`, `201202939672` or `+20 1202939672` are "unknown users".
///
/// [input] may already carry the country code (`+20…`, `0020…`, `20…`), a
/// trunk `0`, spaces/dashes, or Arabic digits.
String buildInternationalPhone({
  required String dialCode,
  required String input,
}) {
  final String raw = toAsciiDigits(input).trim();
  final String dial = _digitsOnly(dialCode);

  if (raw.startsWith('+')) return '+${_digitsOnly(raw)}';
  if (raw.startsWith('00')) return '+${_digitsOnly(raw.substring(2))}';

  final String digits = _digitsOnly(raw);
  // Country code typed into the field without "+" (the field strips "+").
  if (digits.startsWith(dial) &&
      !_isValid('+$dial$digits') &&
      _isValid('+$digits')) {
    return '+$digits';
  }
  return '+$dial${digits.replaceFirst(RegExp(r'^0+'), '')}';
}

/// Phone field formatter: Arabic digits become ASCII, everything that is not a
/// digit is removed, and leading zeros (trunk prefix) are dropped.
class PhoneDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String text =
        _digitsOnly(toAsciiDigits(newValue.text)).replaceFirst(RegExp(r'^0+'), '');
    if (text == newValue.text) return newValue;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
