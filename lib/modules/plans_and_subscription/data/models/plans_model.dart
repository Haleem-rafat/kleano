import 'package:thewasher/utilties/multilingual_helper.dart';

class PlansModel {
  bool? success;
  String? message;
  List<Plan>? plans;

  PlansModel({this.success, this.message, this.plans});

  PlansModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      plans = <Plan>[];
      json['data'].forEach((v) {
        plans!.add(Plan.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (plans != null) {
      data['data'] = plans!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Plan {
  String? sId;
  String? type;
  String? color;
  int? price;
  int? duration;
  String? durationUnit;
  int? usageCount;
  int? pointsToPay;
  List<WashingServices>? washingServices;
  PlanIcon? icon;
  List<String>? description;
  String? createdAt;
  String? updatedAt;

  int? iV;
  bool? isSubscribed;

  Plan(
      {this.sId,
      this.type,
      this.color,
      this.price,
      this.duration,
      this.durationUnit,
      this.usageCount,
      this.pointsToPay,
      this.washingServices,
      this.icon,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.isSubscribed,
      this.iV});

  Plan.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = MultilingualHelper.parseMultilingualField(json['type']);
    color = _parseColor(json['color']);
    price = json['price'];
    duration = json['duration'];
    durationUnit = json['durationUnit'];
    usageCount = json['usageCount'];
    pointsToPay = json['pointsToPay'] ?? 0;
    // if (json['washingServices'] != null) {
    //   if (json['washingServices'] is List) {
    //     washingServices = <WashingServices>[];
    //     json['washingServices'].forEach((v) {
    //       washingServices!.add(WashingServices.fromJson(v));
    //     });

    //     if (washingServices!.isEmpty) {
    //       washingServices = null;
    //     }
    //   }
    // }
    if (json['washingServices'] != null) {
      washingServices = [];

      if (json['washingServices'] is List) {
        for (var item in json['washingServices']) {
          if (item is Map<String, dynamic>) {
            washingServices!.add(WashingServices.fromJson(item));
          } else if (item is String) {
            washingServices!.add(WashingServices(sId: item, name: null));
          }
        }
      }

      if (washingServices!.isEmpty) {
        washingServices = null;
      }
    }
    icon = json['icon'] != null ? PlanIcon.fromJson(json['icon']) : null;
    description = MultilingualHelper.parseMultilingualList(json['description']);
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isSubscribed = json['isSubscribed'] ?? false;
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['type'] = type;
    data['color'] = color;
    data['price'] = price;
    data['duration'] = duration;
    data['durationUnit'] = durationUnit;
    data['usageCount'] = usageCount;
    data['pointsToPay'] = pointsToPay;
    if (washingServices != null) {
      data['washingServices'] =
          washingServices!.map((v) => v.toJson()).toList();
    }
    if (icon != null) {
      data['icon'] = icon!.toJson();
    }
    if (description != null) {
      data['description'] = description!.map((v) => v).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['isSubscribed'] = isSubscribed;
    data['__v'] = iV;
    return data;
  }
}

// Utility method to handle color parsing
String? _parseColor(String? color) {
  if (color == null) return null;

  // Remove the '#' symbol if it exists
  if (color.contains('#')) {
    color = color.replaceAll('#', '');
  }
  return color;
}

class WashingServices {
  String? sId;
  String? name;

  WashingServices({this.sId, this.name});

  WashingServices.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = MultilingualHelper.parseMultilingualField(json['name']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}

class PlanIcon {
  String? iconPath;
  String? iconLink;

  PlanIcon({this.iconPath, this.iconLink});

  PlanIcon.fromJson(dynamic json) {
    if (json is String) {
      // If icon is just a string (ID), use it as iconPath
      iconPath = json;
      iconLink = null;
    } else if (json is Map<String, dynamic>) {
      // If icon is an object, parse the properties
      iconPath = json['iconPath'];
      iconLink = json['iconLink'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['iconPath'] = iconPath;
    data['iconLink'] = iconLink;
    return data;
  }
}
