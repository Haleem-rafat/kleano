import 'package:thewasher/modules/booking/data/models/review_order_model.dart';

class MyBookingModel {
  bool? success;
  int? totalPages;
  int? totalItems;
  List<OrderModel>? data;

  MyBookingModel({this.success, this.totalPages, this.totalItems, this.data});

  MyBookingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    totalPages = json['totalPages'];
    totalItems = json['totalItems'];
    if (json['data'] != null) {
      data = <OrderModel>[];
      json['data'].forEach((v) {
        data!.add(OrderModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['totalPages'] = totalPages;
    data['totalItems'] = totalItems;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

