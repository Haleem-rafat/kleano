import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thewasher/core/resources/constant_manager.dart';

class MoyasarService {
  final String publishApiKey;

  MoyasarService(this.publishApiKey);

  Future<Map<String, dynamic>> createPayment({
    required int amount,
    required String currency,
    required String description,
    required String cardNumber,
    required String cardHolderName,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) async {
    const String paymentUrl = AppConstants.paymentUrl;

    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$publishApiKey:'))}',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> data = {
      'amount': (amount * 100).toInt(),
      'currency': currency,
      'description': description,
      'callback_url': 'https://www.google.com/',
      'source': {
        'type': 'creditcard',
        'number': cardNumber,
        'name': cardHolderName,
        'month': expiryMonth,
        'year': expiryYear,
        'cvv': cvv,
        'cvc': cvv,
      },
    };

    final response = await http.post(
      Uri.parse(paymentUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createApplePayPayment({
    required int amount,
    required String currency,
    required String description,
    required String paymentToken,
    Map<String, dynamic>? metadata,
  }) async {
    const String paymentUrl = AppConstants.paymentUrl;

    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$publishApiKey:'))}',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> data = {
      'amount': (amount * 100).toInt(),
      'currency': currency,
      'description': description,
      'callback_url': 'https://www.google.com/',
      'source': {
        'type': 'applepay',
        'token': paymentToken,
      },
      'metadata': ?metadata,
    };

    final response = await http.post(
      Uri.parse(paymentUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create Apple Pay payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getPayment(String paymentId) async {
    final String paymentUrl = '${AppConstants.paymentUrl}/$paymentId';

    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$publishApiKey:'))}',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse(paymentUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get payment: ${response.body}');
    }
  }
}
