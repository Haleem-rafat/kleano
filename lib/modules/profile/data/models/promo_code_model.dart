import 'package:thewasher/utilties/app_date_formatter.dart';

class PromoCodeModel {
  String? sId;
  String? code;
  String? expiryDate;
  int? discountPercentage;
  int? discountFixedNumber;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;
  int? numberOfUses;

  PromoCodeModel({
    this.sId,
    this.code,
    this.expiryDate,
    this.discountPercentage,
    this.discountFixedNumber,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.numberOfUses,
  });

  PromoCodeModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    code = json['code'];
    expiryDate = json['expiryDate'] != null
        ? AppDateFormatter.dateToStringFormat(
            DateTime.parse(json['expiryDate']).toLocal(),
          )
        : null;
    discountPercentage = json['discountPercentage'];
    discountFixedNumber = json['discountFixedNumber'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    numberOfUses = json['numberOfUses'];
  }
}
