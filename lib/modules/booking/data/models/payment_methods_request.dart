class PaymentDetailsRequest {
  final String? name;
  final String? number;
  final String? cvc;
  final String? month;
  final String? year;

  PaymentDetailsRequest({
    this.name,
    this.number,
    this.cvc,
    this.month,
    this.year,
  });
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'cvc': cvc,
      'month': month,
      'year': year,
    };
  }
}
