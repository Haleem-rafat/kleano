class TotalCommissionModel {
  final CommissionPeriod today;
  final CommissionPeriod allTime;
  final CommissionPeriod allWeekends;

  TotalCommissionModel({
    required this.today,
    required this.allTime,
    required this.allWeekends,
  });

  factory TotalCommissionModel.fromJson(Map<String, dynamic> json) {
    return TotalCommissionModel(
      today: CommissionPeriod.fromJson(json['today'] ?? {}),
      allTime: CommissionPeriod.fromJson(json['allTime'] ?? {}),
      allWeekends: CommissionPeriod.fromJson(json['allWeekends'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today.toJson(),
      'allTime': allTime.toJson(),
      'allWeekends': allWeekends.toJson(),
    };
  }
}

class CommissionPeriod {
  final num totalCommission;
  final int ordersCount;

  CommissionPeriod({
    required this.totalCommission,
    required this.ordersCount,
  });

  factory CommissionPeriod.fromJson(Map<String, dynamic> json) {
    return CommissionPeriod(
      totalCommission: json['totalCommission'] ?? 0,
      ordersCount: json['ordersCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCommission': totalCommission,
      'ordersCount': ordersCount,
    };
  }
}
