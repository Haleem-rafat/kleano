class ApplyPoint {
  double? totalPrice;
  double? totalPay;

  ApplyPoint({
    this.totalPay,
    this.totalPrice,
  });

  ApplyPoint.fromJson(Map<String, dynamic> json) {
    totalPay = json['totalPay'].toDouble();
    totalPrice = json['totalPrice'].toDouble();
  }
}
