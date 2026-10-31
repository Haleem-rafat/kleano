import 'package:thewasher/utilties/multilingual_helper.dart';

class AddOnsModel {
  String? sId;
  String? name;
  int? price;
  Icon? icon;
  String? createdAt;
  String? updatedAt;
  int? iV;

  AddOnsModel({
    this.sId,
    this.name,
    this.price,
    this.icon,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  AddOnsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = MultilingualHelper.parseMultilingualField(json['name']);
    price = json['price'];
    icon = json['icon'] != null ? Icon.fromJson(json['icon']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }
}

class Icon {
  String? sId;
  String? iconPath;
  String? iconLink;

  Icon({this.sId, this.iconPath, this.iconLink});

  Icon.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    iconPath = json['iconPath'];
    iconLink = json['iconLink'];
  }
}
