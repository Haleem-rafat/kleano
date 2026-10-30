import 'package:thewasher/utilties/multilingual_helper.dart';

class ServiceModel {
  String? sId;
  String? name;
  List<String>? description;
  int? duration;
  String? durationUnit;
  int? price;
  // int? pointsToPay;
  IconModel? icon;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? type;

  ServiceModel({
    this.sId,
    this.name,
    this.description,
    this.duration,
    this.durationUnit,
    this.price,
    // this.pointsToPay,
    this.icon,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.type,
  });

  ServiceModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = MultilingualHelper.parseMultilingualField(json['name']);
    description = MultilingualHelper.parseMultilingualList(json['description']);
    duration = json['duration'];
    durationUnit = json['durationUnit'];
    price = json['price'];
    // pointsToPay = json['pointsToPay'] ?? 0;
    icon = json['icon'] != null ? IconModel.fromJson(json['icon']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    type = json['type'];
  }
}

class IconModel {
  String? sId;
  String? iconPath;
  String? iconLink;

  IconModel({this.sId, this.iconPath, this.iconLink});

  IconModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    iconPath = json['iconPath'];
    iconLink = json['iconLink'] ??
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTeujOaRWnmiTkG15-RkZrieVZ_JKumVf1CPQ&s';
  }
}
