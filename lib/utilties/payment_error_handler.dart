import 'package:flutter_translate/flutter_translate.dart';

/// Comprehensive payment error handler for all payment gateway errors
///
/// This class handles all types of payment errors that can occur during
/// the payment process. Errors are categorized into:
///
/// **Customer-Side Errors:**
/// - INSUFFICIENT_FUNDS: Not enough balance on the card
/// - TIMEOUT: Payment took too long (>15 minutes)
/// - INCORRECT_CVV/CVC: Security code entered incorrectly
/// - INCORRECT_PIN: PIN entered incorrectly
/// - EXPIRED_CARD: Card has expired
/// - LOST_CARD: Card reported as lost
/// - STOLEN_CARD: Card reported as stolen
/// - INVALID_CARD: Card information is invalid
/// - CARD_NOT_ENROLLED: Card not registered for online payments
///
/// **Bank/Gateway-Side Errors:**
/// - DECLINED: Transaction declined by bank
/// - UNSPECIFIED_FAILURE: Bank declined for unknown reason
/// - REFERRED: Problem with credit card number
/// - BLOCKED: Transaction blocked (possible fraud suspicion)
/// - DO_NOT_HONOR: Bank declined without specific reason
/// - RESTRICTED_CARD: Card has restrictions
/// - TRANSACTION_NOT_ALLOWED: Transaction type not allowed
/// - SERVICE_NOT_ALLOWED: Service not allowed for card
/// - STOP_PAYMENT_ORDER: Stop payment order in effect
/// - TRANSACTION_LIMIT_EXCEEDED: Amount exceeds card limit
/// - WITHDRAWAL_LIMIT_EXCEEDED: Daily withdrawal limit exceeded
/// - CARD_NOT_SUPPORTED: Card type not supported
///
/// **3D Secure Errors:**
/// - AUTHENTICATION_FAILED: 3D Secure authentication unsuccessful
/// - AUTHENTICATION_ATTEMPTED: Cardholder/bank not 3D enrolled
/// - AUTHENTICATION_NOT_AVAILABLE: 3D authentication unavailable
/// - CARD_NOT_ENROLLED: Card not listed for online payment
/// - Missing parameter: Authentication error
/// - Visa/Mastercard not configured: Merchant account issue
/// - Invalid card number: Card number entered incorrectly
/// - Amount exceeds limit: Amount too large for transaction
///
/// **Technical Errors:**
/// - TIMED_OUT: Bank connection timeout
/// - SECURITY_VIOLATION: Security issue detected
/// - TRY_AGAIN_LATER: Service temporarily unavailable
///
/// Usage:
/// ```dart
/// final errorMessage = PaymentErrorHandler.getErrorMessage(url);
/// if (errorMessage != null) {
///   // Show error to user
/// }
/// ```
class PaymentErrorHandler {
  /// Determines the user-friendly error message based on the URL or error code
  static String? getErrorMessage(String url) {
    // Success case
    if (url.contains('approved') ||
        url.contains('success') ||
        url.contains('APPROVED')) {
      return null; // No error
    }

    // Insufficient funds
    if (_containsAny(
        url, ['INSUFFICIENT_FUNDS', 'INSUFFICIENT', 'insufficient'])) {
      return translate('insufficientFundsError');
    }

    // Timeout errors
    if (_containsAny(url, ['TIMED_OUT', 'TIMEOUT', 'timeout', 'TIME_OUT'])) {
      return translate('timeoutError');
    }

    // CVV/CVC errors
    if (_containsAny(url, [
      'INCORRECT_CVV',
      'INCORRECT_CVC',
      'CVV',
      'CVC',
      'INVALID_CVV',
      'INVALID_CVC',
      'security_code_invalid'
    ])) {
      return translate('incorrectCvvError');
    }

    // Declined errors
    if (_containsAny(url, ['DECLINED', 'declined', 'GENERIC_DECLINE'])) {
      return translate('genericDeclineError');
    }

    // Unspecified failure
    if (_containsAny(
        url, ['UNSPECIFIED_FAILURE', 'UNSPECIFIED', 'unspecified'])) {
      return translate('unspecifiedFailureError');
    }

    // Referred
    if (_containsAny(url, ['REFERRED', 'referred', 'refer_to_issuer'])) {
      return translate('referredError');
    }

    // Blocked
    if (_containsAny(url, ['BLOCKED', 'blocked', 'blocked_card'])) {
      return translate('blockedError');
    }

    // 3D Secure - Authentication Failed
    if (_containsAny(url, [
      'AUTHENTICATION_FAILED',
      'authentication_failed',
      'authentication declined',
      'Card authentication declined',
      '3-D Secure',
      '3D Secure',
      '3DS:',
      '3DS ',
      'threeDSecure'
    ])) {
      return translate('threeDSecureAuthFailedError');
    }

    // 3D Secure - Authentication Attempted
    if (_containsAny(
        url, ['AUTHENTICATION_ATTEMPTED', 'authentication_attempted'])) {
      return translate('threeDSecureAttemptedError');
    }

    // 3D Secure - Authentication Not Available
    if (_containsAny(url,
        ['AUTHENTICATION_NOT_AVAILABLE', 'authentication_not_available'])) {
      return translate('threeDSecureNotAvailableError');
    }

    // 3D Secure - Missing Parameter
    if (_containsAny(url, ['Missing parameter', 'missing_parameter'])) {
      return translate('threeDSecureMissingParamError');
    }

    // 3D Secure - Card Not Enrolled
    if (_containsAny(
        url, ['CARD_NOT_ENROLLED', 'not_enrolled', 'notEnrolled'])) {
      return translate('threeDSecureNotEnrolledError');
    }

    // 3D Secure - Visa not configured
    if (_containsAny(url, ['card type VC', 'Visa', 'visa_not_configured'])) {
      if (url.contains('Relationship not found')) {
        return translate('visaNotConfiguredError');
      }
    }

    // 3D Secure - Mastercard not configured
    if (_containsAny(
        url, ['card type MC', 'Mastercard', 'mastercard_not_configured'])) {
      if (url.contains('Relationship not found')) {
        return translate('mastercardNotConfiguredError');
      }
    }

    // Invalid card number
    if (_containsAny(url, [
      'invalid card',
      'Cannot determine card brand',
      'Unable to determine card payment',
      'invalid_card_number'
    ])) {
      return translate('invalidCardNumberError');
    }

    // Amount exceeds limit
    if (_containsAny(url, [
      'Amount exceeds',
      'exceeds maximum',
      'LIMIT_EXCEEDED',
      'amount_too_large'
    ])) {
      return translate('amountExceedsLimitError');
    }

    // Expired card
    if (_containsAny(
        url, ['EXPIRED_CARD', 'EXPIRED', 'expired', 'card_expired'])) {
      return translate('expiredCardError');
    }

    // Lost card
    if (_containsAny(url, ['LOST_CARD', 'LOST CARD', 'lost_card'])) {
      return translate('lostCardError');
    }

    // Stolen card
    if (_containsAny(url, ['STOLEN_CARD', 'STOLEN CARD', 'stolen_card'])) {
      return translate('stolenCardError');
    }

    // Invalid card
    if (_containsAny(url, ['INVALID_CARD', 'INVALID', 'invalid'])) {
      return translate('invalidCardError');
    }

    // Card not supported
    if (_containsAny(
        url, ['CARD_NOT_SUPPORTED', 'NOT_SUPPORTED', 'not_supported'])) {
      return translate('cardNotSupportedError');
    }

    // Transaction not allowed
    if (_containsAny(url, [
      'TRANSACTION_NOT_ALLOWED',
      'NOT_ALLOWED',
      'not_allowed',
      'transaction_not_permitted'
    ])) {
      return translate('transactionNotAllowedError');
    }

    // Do not honor
    if (_containsAny(url, ['DO_NOT_HONOR', 'HONOR', 'do_not_honor'])) {
      return translate('doNotHonorError');
    }

    // Restricted card
    if (_containsAny(url, ['RESTRICTED_CARD', 'RESTRICTED', 'restricted'])) {
      return translate('restrictedCardError');
    }

    // Security violation
    if (_containsAny(
        url, ['SECURITY_VIOLATION', 'SECURITY', 'security_violation'])) {
      return translate('securityViolationError');
    }

    // Service not allowed
    if (_containsAny(
        url, ['SERVICE_NOT_ALLOWED', 'SERVICE', 'service_not_allowed'])) {
      return translate('serviceNotAllowedError');
    }

    // Stop payment order
    if (_containsAny(url, ['STOP_PAYMENT_ORDER', 'STOP', 'stop_payment'])) {
      return translate('stopPaymentOrderError');
    }

    // Transaction limit exceeded
    if (_containsAny(url, [
      'TRANSACTION_LIMIT_EXCEEDED',
      'LIMIT_EXCEEDED',
      'transaction_limit'
    ])) {
      return translate('transactionLimitExceededError');
    }

    // Withdrawal limit exceeded
    if (_containsAny(
        url, ['WITHDRAWAL_LIMIT_EXCEEDED', 'WITHDRAWAL', 'withdrawal_limit'])) {
      return translate('withdrawalLimitExceededError');
    }

    // Try again later
    if (_containsAny(url, ['TRY_AGAIN_LATER', 'LATER', 'try_again'])) {
      return translate('tryAgainLaterError');
    }

    // Incorrect PIN
    if (_containsAny(url, ['INCORRECT_PIN', 'PIN', 'invalid_pin'])) {
      return translate('incorrectPinError');
    }

    // Generic payment error
    if (_containsAny(
        url, ['error', 'failed', 'failure', 'ERROR', 'FAILED', 'FAILURE'])) {
      return translate('paymentFailedGeneric');
    }

    return null; // No error detected
  }

  /// Helper method to check if URL contains any of the specified keywords
  static bool _containsAny(String url, List<String> keywords) {
    return keywords.any((keyword) => url.contains(keyword));
  }

  /// Get error category for analytics or logging
  static String getErrorCategory(String url) {
    if (_containsAny(url, ['INSUFFICIENT_FUNDS', 'INSUFFICIENT'])) {
      return 'insufficient_funds';
    }
    if (_containsAny(url, ['TIMED_OUT', 'TIMEOUT'])) {
      return 'timeout';
    }
    if (_containsAny(url, ['CVV', 'CVC'])) {
      return 'cvv_error';
    }
    if (_containsAny(url, ['DECLINED'])) {
      return 'declined';
    }
    if (_containsAny(url, ['3-D Secure', '3D Secure', 'AUTHENTICATION'])) {
      return '3d_secure_error';
    }
    if (_containsAny(url, ['EXPIRED'])) {
      return 'expired_card';
    }
    if (_containsAny(url, ['LOST', 'STOLEN'])) {
      return 'lost_stolen_card';
    }
    return 'general_error';
  }

  /// Check if error is recoverable (user can retry)
  static bool isRecoverableError(String url) {
    // Errors that user can potentially fix
    final recoverableErrors = [
      'INSUFFICIENT_FUNDS',
      'INCORRECT_CVV',
      'INCORRECT_PIN',
      'TIMED_OUT',
      'TRY_AGAIN_LATER',
      'UNSPECIFIED_FAILURE',
    ];

    return recoverableErrors.any((error) => url.contains(error));
  }

  /// Check if user should contact bank
  static bool shouldContactBank(String url) {
    final bankContactErrors = [
      'DECLINED',
      'DO_NOT_HONOR',
      'REFERRED',
      'BLOCKED',
      'RESTRICTED',
      'TRANSACTION_NOT_ALLOWED',
      'CARD_NOT_ENROLLED',
      'LOST_CARD',
      'STOLEN_CARD',
    ];

    return bankContactErrors.any((error) => url.contains(error));
  }

  /// Check if user should use different payment method
  static bool shouldTryDifferentPaymentMethod(String url) {
    final differentMethodErrors = [
      'CARD_NOT_SUPPORTED',
      'SERVICE_NOT_ALLOWED',
      'STOP_PAYMENT_ORDER',
      'EXPIRED_CARD',
      'INVALID_CARD',
    ];

    return differentMethodErrors.any((error) => url.contains(error));
  }
}
