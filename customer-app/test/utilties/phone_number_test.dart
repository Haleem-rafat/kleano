import 'package:flutter_test/flutter_test.dart';
import 'package:thewasher/utilties/phone_number.dart';

void main() {
  // The backend matches the phone string exactly: only "+201202939672" finds
  // the account (check-phone returns isExist:false for every other spelling).
  group('buildInternationalPhone', () {
    const String expected = '+201202939672';

    final Map<String, String> egyptInputs = <String, String>{
      'national number': '1202939672',
      'with trunk 0': '01202939672',
      'with spaces': '120 293 9672',
      'with dashes': '120-293-9672',
      'country code without +': '201202939672',
      'country code with +': '+201202939672',
      'country code with + and spaces': '+20 1202939672',
      'country code with 00': '00201202939672',
      'Arabic-Indic digits': '١٢٠٢٩٣٩٦٧٢',
      'Arabic-Indic with trunk 0': '٠١٢٠٢٩٣٩٦٧٢',
      'Persian digits': '۱۲۰۲۹۳۹۶۷۲',
    };
    egyptInputs.forEach((String name, String input) {
      test('Egypt: $name', () {
        expect(buildInternationalPhone(dialCode: '+20', input: input), expected);
      });
    });

    test('dial code without + is accepted', () {
      expect(buildInternationalPhone(dialCode: '20', input: '1202939672'),
          expected);
    });

    test('Saudi default still works', () {
      expect(buildInternationalPhone(dialCode: '+966', input: '533720654'),
          '+966533720654');
      expect(buildInternationalPhone(dialCode: '+966', input: '0533720654'),
          '+966533720654');
    });

    test('a full number typed under the wrong country keeps its own code', () {
      expect(buildInternationalPhone(dialCode: '+966', input: '+201202939672'),
          expected);
    });
  });

  group('PhoneDigitsFormatter', () {
    TextEditingValue format(String text) => PhoneDigitsFormatter()
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));

    test('converts Arabic digits instead of dropping them', () {
      expect(format('١٢٠٢٩٣٩٦٧٢').text, '1202939672');
    });

    test('drops leading zeros, spaces and symbols', () {
      expect(format('0120 293-9672').text, '1202939672');
    });
  });
}
