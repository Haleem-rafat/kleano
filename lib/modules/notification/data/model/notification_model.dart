import 'package:thewhsherbiker/utilties/app_date_formatter.dart';

class NotificationModel {
  Message? message;
  String? sId;
  String? receiver;
  String? receiverModel;
  String? clickableItem;
  String? clickableItemModel;
  bool? isRead;
  String? type;
  String? createdAt;
  String? createdAtTime;
  String? timeNow;
  String? updatedAt;
  int? iV;

  NotificationModel({
    this.message,
    this.sId,
    this.receiver,
    this.receiverModel,
    this.clickableItem,
    this.clickableItemModel,
    this.isRead,
    this.type,
    this.createdAt,
    this.createdAtTime,
    this.timeNow,
    this.updatedAt,
    this.iV,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    message =
        json['message'] != null ? Message.fromJson(json['message']) : null;
    sId = json['_id'];
    receiver = json['receiver'];
    receiverModel = json['receiverModel'];
    clickableItem = json['clickableItem'];
    clickableItemModel = json['clickableItemModel'];
    isRead = json['isRead'];
    type = json['type'];
    createdAt = AppDateFormatter.dateToStringToServer(
      DateTime.parse(json['createdAt']).toLocal(),
    );
    createdAtTime = AppDateFormatter.dateToStringHHMMA(
      DateTime.parse(json['createdAt']).toLocal(),
    );
    timeNow = AppDateFormatter.dateToStringToServer(
      DateTime.now().toLocal(),
    );
    updatedAt = json['updatedAt'];
    iV = json['__v'];
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
}
