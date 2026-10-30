import 'package:thewasher/utilties/app_date_formatter.dart';

class NotificationsModel {
  bool? success;
  int? totalPages;
  int? totalItems;
  List<Notifications>? data;

  NotificationsModel({this.success, this.totalPages, this.totalItems, this.data});

  NotificationsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    totalPages = json['totalPages'];
    totalItems = json['totalItems'];
    if (json['data'] != null) {
      data = <Notifications>[];
      json['data'].forEach((v) {
        data!.add(Notifications.fromJson(v));
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

class Notifications {
  Message? message;
  String? sId;
  bool? isRead;
  String? type;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? orderId;
  String? clickableItemModel;
  String? createdAtByTime;
  String? timeNow;

  Notifications({
    this.message,
    this.sId,
    this.isRead,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.orderId,
    this.clickableItemModel,
    this.createdAtByTime,
    this.timeNow,
  });

  Notifications.fromJson(Map<String, dynamic> json) {
    message = json['message'] != null ? Message.fromJson(json['message']) : null;
    sId = json['_id'];
    isRead = json['isRead'];
    type = json['type'];
    // createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    orderId = json['clickableItem'];
    clickableItemModel = json['clickableItemModel'];
    createdAt = AppDateFormatter.allDate(
      DateTime.parse(json['createdAt']).toLocal(),
    );
    createdAtByTime = AppDateFormatter.dateToStringHHMMA(
      DateTime.parse(json['createdAt']).toLocal(),
    );
    timeNow = AppDateFormatter.allDate(
      DateTime.now().toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (message != null) {
      data['message'] = message!.toJson();
    }
    data['_id'] = sId;
    data['isRead'] = isRead;
    data['type'] = type;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['clickableItem'] = orderId;
    data['clickableItemModel'] = clickableItemModel;
    return data;
  }
}

class Message {
  String? arTitle;
  String? arBody;
  String? enTitle;
  String? enBody;

  Message({this.arTitle, this.arBody, this.enTitle, this.enBody});

  Message.fromJson(Map<String, dynamic> json) {
    arTitle = json['arTitle'];
    arBody = json['arBody'];
    enTitle = json['enTitle'];
    enBody = json['enBody'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['arTitle'] = arTitle;
    data['arBody'] = arBody;
    data['enTitle'] = enTitle;
    data['enBody'] = enBody;
    return data;
  }
}
