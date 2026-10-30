class CardValidator {
  static String? validateCardHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the cardholder\'s name';
    }
    return null;
  }

  static String? validateCardNumber(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter your card number';
    }
    String cardNumber = input.replaceAll(RegExp(r'\D'), '');
    if (cardNumber.length < 8) {
      return 'Invalid card number';
    }
    return null;
  }

  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    if (!value.contains(RegExp(r'(/)'))) return 'Please enter a valid date';

    var split = value.split(RegExp(r'(/)'));
    int month = int.parse(split[0]);
    int year = int.parse(split[1]);

    if ((month < 1) || (month > 12)) return 'Please enter a valid month';

    final expiryDate = DateTime(_convertYearTo4Digits(year), month);
    final now = DateTime.now();

    if (expiryDate.isBefore(now)) return 'The card has expired';
    return null;
  }

  static String? validateCVC(String? input) {
    if (input == null || input.isEmpty) return 'CVC is required';
    if (input.length < 3 || input.length > 4) {
      return 'CVC must be 3 or 4 digits';
    }
    return null;
  }

  static int _convertYearTo4Digits(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }
}
