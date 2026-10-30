import 'package:thewasher/modules/Home/data/model/add_ons_model.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/modules/tracking_order/data/models/accepted_biker_model.dart';

class ReviewOrderModel {
  bool? success;
  OrderModel? data;

  ReviewOrderModel({this.success, this.data});

  ReviewOrderModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data']['createdOrder'] != null
        ? OrderModel.fromJson(json['data']['createdOrder'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data']['createdOrder'] = this.data!.toJson();
    }
    return data;
  }
}

class OrderModel {
  String? sId;
  List<ServiceModel>? washingServices;
  List<AddOnsModel>? addOns;
  Vehicle? vehicle;
  Location? location;
  bool? isAssigned;
  bool? isScheduled;
  String? startTime;
  int? totalDuration;
  String? status;
  String? description;
  String? type;
  String? paymentType;
  double? totalPrice;
  double? discount;
  double? totalPay;
  bool? isPointsApplied;
  String? createdAt;
  String? updatedAt;
  int? iV;
  Biker? biker;
  PromoCode? promoCode;
  String? onTheWayAt;
  String? onWashingAt;
  String? endTime;
  double? ratingOfBiker;
  num? points;
  bool? isCarFreshened;
  String? beforeWashImage;
  String? afterWashImage;

  OrderModel({
    this.sId,
    this.washingServices,
    this.addOns,
    this.vehicle,
    this.location,
    this.startTime,
    this.totalDuration,
    this.status,
    this.description,
    this.type,
    this.totalPrice,
    this.discount,
    this.totalPay,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.paymentType,
    this.promoCode,
    this.biker,
    this.onTheWayAt,
    this.endTime,
    this.onWashingAt,
    this.isAssigned,
    this.isScheduled,
    this.isPointsApplied,
    this.ratingOfBiker,
    this.points,
    this.isCarFreshened,
    this.beforeWashImage,
    this.afterWashImage,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['washingServices'] != null) {
      washingServices = <ServiceModel>[];
      json['washingServices'].forEach((v) {
        washingServices!.add(ServiceModel.fromJson(v));
      });
    }
    if (json['addOns'] != null) {
      addOns = <AddOnsModel>[];
      json['addOns'].forEach((v) {
        addOns!.add(AddOnsModel.fromJson(v));
      });
    }
    vehicle =
        json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null;
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    isAssigned = json['isAssigned'];
    isScheduled = json['isScheduled'];
    startTime = json['startTime'];
    totalDuration = json['totalDuration'];
    status = json['status'];
    description = json['description'];
    type = json['type'];
    totalPrice = json['totalPrice'].toDouble();
    discount = json['discount'].toDouble();
    totalPay = json['totalPay'].toDouble();
    isPointsApplied = json['isPointsApplied'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    paymentType = json['paymentType'];
    promoCode = json['promoCode'] != null
        ? PromoCode.fromJson(json['promoCode'])
        : null;
    biker = json['biker'] != null ? Biker.fromJson(json['biker']) : null;
    onTheWayAt = json['OnTheWayAt'];
    onWashingAt = json['onWashingAt'];
    endTime = json['endTime'];
    ratingOfBiker =
        json['ratingOfBiker'] != null ? json['ratingOfBiker'].toDouble() : 0.0;
    points = json['points'];
    isCarFreshened = json['isCarFreshened'];
    beforeWashImage = json['carBeforeWashLink'];
    afterWashImage = json['carAfterWashLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    // if (washingServices != null) {
    //   data['washingServices'] = washingServices!.map((ServiceModel v) => v.toJson()).toList();
    // }
    // if (addOns != null) {
    //   data['addOns'] = addOns!.map((v) => v.toJson()).toList();
    // }
    if (vehicle != null) {
      data['vehicle'] = vehicle!.toJson();
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['isAssigned'] = isAssigned;
    data['isScheduled'] = isScheduled;
    data['startTime'] = startTime;
    data['totalDuration'] = totalDuration;
    data['status'] = status;
    data['description'] = description;
    data['type'] = type;
    data['totalPrice'] = totalPrice;
    data['discount'] = discount;
    data['totalPay'] = totalPay;
    data['isPointsApplied'] = isPointsApplied;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['paymentType'] = paymentType;
    if (promoCode != null) {
      data['promoCode'] = promoCode!.toJson();
      if (biker != null) {
        data['biker'] = biker!.toJson();
      }
    }
    data['OnTheWayAt'] = onTheWayAt;
    data['onWashingAt'] = onWashingAt;
    data['endTime'] = endTime;
    data['ratingOfBiker'] = ratingOfBiker;
    data['isCarFreshened'] = isCarFreshened;
    data['carBeforeWashImage'] = beforeWashImage;
    data['carAfterWashImage'] = afterWashImage;
    return data;
  }
}

class Vehicle {
  String? sId;
  String? type;
  String? brand;
  String? model;
  String? plateNumber;
  String? color;
  String? imageLink;

  Vehicle(
      {this.sId,
      this.type,
      this.brand,
      this.model,
      this.plateNumber,
      this.color});

  Vehicle.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    brand = json['brand'];
    model = json['model'];
    plateNumber = json['plateNumber'];
    color = json['color'];
    imageLink = json['imageLink'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['type'] = type;
    data['brand'] = brand;
    data['model'] = model;
    data['plateNumber'] = plateNumber;
    data['color'] = color;
    data['imageLink'] = imageLink;
    return data;
  }
}

class Location {
  String? sId;
  double? latitude;
  double? longitude;
  String? streetName;
  String? subAdministrativeArea;
  bool? isSaved;
  String? savedName;

  Location(
      {this.sId,
      this.latitude,
      this.longitude,
      this.streetName,
      this.subAdministrativeArea,
      this.isSaved,
      this.savedName});

  Location.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    streetName = json['streetName'];
    subAdministrativeArea = json['subAdministrativeArea'];
    isSaved = json['isSaved'];
    savedName = json['savedName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['streetName'] = streetName;
    data['subAdministrativeArea'] = subAdministrativeArea;
    data['isSaved'] = isSaved;
    data['savedName'] = savedName;
    return data;
  }
}

class PromoCode {
  String? sId;
  String? code;

  PromoCode({this.sId, this.code});

  PromoCode.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['code'] = code;
    return data;
  }
}
