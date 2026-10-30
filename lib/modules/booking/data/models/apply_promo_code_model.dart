class ApplyPromoCodeModel {
  bool? success;
  TotalPayModel? data;

  ApplyPromoCodeModel({this.success, this.data});

  ApplyPromoCodeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? TotalPayModel.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class TotalPayModel {
  String? sId;
  double? discount;
  double? totalPay;
  double? totalPrice;

  TotalPayModel({this.sId, this.discount, this.totalPay, this.totalPrice});

  TotalPayModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    discount = json['discount'].toDouble() ?? 0.0;
    totalPay = json['totalPay'].toDouble();
    totalPrice = json['totalPrice'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['discount'] = discount;
    data['totalPay'] = totalPay;
    data['totalPrice'] = totalPrice;
    return data;
  }
}

class NewPromoCodeModel {
  num? totalPayAfterDiscount;
  num? discountAmount;

  NewPromoCodeModel({this.totalPayAfterDiscount, this.discountAmount});

  NewPromoCodeModel.fromJson(Map<String, dynamic> json) {
    totalPayAfterDiscount = json['totalPayAfterDiscount'].toDouble();
    discountAmount = json['discountAmount'].toDouble();
  }
}
