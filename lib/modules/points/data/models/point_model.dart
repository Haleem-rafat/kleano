class PointModel{
  int? points;
  double? pointsExchange;
  int? redeemLimit;

  PointModel({this.points, this.pointsExchange, this.redeemLimit});

  PointModel.fromJson(Map<String, dynamic> json) {
    points = json['points'];
    pointsExchange = json['pointsExchange'].toDouble();
    redeemLimit = json['redeemLimit'];
  }
}