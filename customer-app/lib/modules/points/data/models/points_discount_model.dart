class PointsDiscountModel {
  num? points;
  num? discountAmount;
  num? redeemLimit;
  num? exchangePercentage;

  PointsDiscountModel({
    this.points,
    this.discountAmount,
    this.redeemLimit,
    this.exchangePercentage,
  });

  PointsDiscountModel.fromJson(Map<String, dynamic> json) {
    points = json['points']?.toDouble() ?? 0;
    discountAmount = json['discountAmount']?.toDouble() ?? 0;
    redeemLimit = json['redeemLimit']?.toDouble() ?? 0;
    exchangePercentage = json['exchangePercentage']?.toDouble() ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['points'] = points;
    data['discountAmount'] = discountAmount;
    data['redeemLimit'] = redeemLimit;
    data['exchangePercentage'] = exchangePercentage;
    return data;
  }
}
