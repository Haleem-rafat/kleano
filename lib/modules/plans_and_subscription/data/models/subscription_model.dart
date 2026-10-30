import 'package:thewasher/modules/plans_and_subscription/data/models/plans_model.dart';

class SubscriptionUserModel {
  bool? success;
  Subscription? data;

  SubscriptionUserModel({this.success, this.data});

  SubscriptionUserModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Subscription.fromJson(json['data']) : null;
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

class Subscription {
  String? sId;
  String? user;
  Plan? plan;
  int? remainingWashes;
  int? washesCount;
  String? expiryDate;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Subscription(
      {this.sId,
      this.user,
      this.plan,
      this.remainingWashes,
      this.washesCount,
      this.expiryDate,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Subscription.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] is Map
        ? json['user']['userName']
        : json['user']?.toString();
    plan = json['plan'] != null ? Plan.fromJson(json['plan']) : null;
    remainingWashes = json['remainingWashes'];
    washesCount = json['washesCount'];
    expiryDate = json['expiryDate'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['user'] = user;
    if (plan != null) {
      data['plan'] = plan!.toJson();
    }
    data['remainingWashes'] = remainingWashes;
    data['washesCount'] = washesCount;
    data['expiryDate'] = expiryDate;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

// class Plan {
//   String? sId;
//   String? type;

//   Plan({this.sId, this.type});

//   Plan.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     type = json['type'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['_id'] = sId;
//     data['type'] = type;
//     return data;
//   }
// }
