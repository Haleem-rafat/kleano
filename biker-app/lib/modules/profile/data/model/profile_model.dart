import 'package:thewhsherbiker/modules/profile/data/model/total_commission_model.dart';
import 'package:thewhsherbiker/utilties/app_date_formatter.dart';

class ProfileModel {
  String? sId;
  String? userName;
  String? phone;
  bool? isDeleted;
  City? city;
  String? nationalId;
  String? status;
  CreatedBy? createdBy;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? imageLink;
  String? imagePath;
  num? rating;
  int? totalWashes;
  num? commission;
  num? minimumCommission;
  int? ordersBeforeCommission;
  TotalCommissionModel? totalCommission;

  ProfileModel({
    this.sId,
    this.userName,
    this.phone,
    this.isDeleted,
    this.city,
    this.nationalId,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.imageLink,
    this.imagePath,
    this.rating,
    this.totalWashes,
    this.commission,
    this.minimumCommission,
    this.ordersBeforeCommission,
    this.totalCommission,
  });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userName = json['userName'];
    phone = json['phone'];
    isDeleted = json['isDeleted'];
    if (json['city'] != null) {
      if (json['city'] is Map<String, dynamic>) {
        city = City.fromJson(json['city']);
      } else if (json['city'] is String) {
        city = City(sId: json['city'], name: null);
      }
    }
    // city = json['city'] != null ? new City.fromJson(json['city']) : null;
    nationalId = json['nationalId'];
    status = json['status'] ?? "";
    createdBy = json['createdBy'] != null
        ? CreatedBy.fromJson(json['createdBy'])
        : null;
    createdAt = AppDateFormatter.dateWithDash(
      DateTime.parse(json['createdAt']).toLocal(),
    );
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    imageLink = json['imageLink'];
    imagePath = json['imagePath'];
    rating = json['rating'];
    totalWashes = json['totalWashes'];
    commission = json['commission'];
    minimumCommission = json['minimumCommission'];
    ordersBeforeCommission = json['ordersBeforeCommission'];
  }
}

class City {
  Name? name;
  String? sId;

  City({this.name, this.sId});

  City.fromJson(Map<String, dynamic> json) {
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    sId = json['_id'];
  }
}

class Name {
  String? ar;
  String? en;

  Name({this.ar, this.en});

  Name.fromJson(Map<String, dynamic> json) {
    ar = json['ar'];
    en = json['en'];
  }
}

class CreatedBy {
  String? sId;
  String? userName;

  CreatedBy({this.sId, this.userName});

  CreatedBy.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userName = json['userName'];
  }
}
