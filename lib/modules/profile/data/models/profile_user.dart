class UserProfile {
  bool? success;
  Profile? data;

  UserProfile({this.success, this.data});

  UserProfile.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Profile.fromJson(json['data']) : null;
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

class Profile {
  Location? location;
  String? sId;
  String? userName;
  String? phone;
  String? email;
  int? points;
  double? walletBalance;
  String? imageLink;
  String? imagePath;
  List<String>? fcmTokens;
  bool? isDeleted;
  bool? isAllowNotification;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? gender;
  bool? isSubscribed;
  double? rating;
  String? dob;

  Profile({
    this.location,
    this.sId,
    this.userName,
    this.phone,
    this.email,
    this.imageLink,
    this.imagePath,
    this.points,
    this.walletBalance,
    this.fcmTokens,
    this.isDeleted,
    this.isAllowNotification,
    this.createdAt,
    this.updatedAt,
    this.gender,
    this.isSubscribed,
    this.iV,
    this.rating,
    this.dob,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null ? Location.fromJson(json['location']) : null;
    sId = json['_id'];
    userName = json['userName'];
    phone = json['phone'];
    email = json['email'];
    points = json['points'];
    walletBalance = json['walletBalance'].toDouble();
    imageLink = json['imageLink'];
    imagePath = json['imagePath'];
    gender = json['gender'];
    if (json['fcmTokens'] != null) {
      fcmTokens = <String>[];
      // json['fcmTokens'].forEach((v) {
      //   fcmTokens!.add(String.fromJson(v));
      // });
    }
    isDeleted = json['isDeleted'];
    isAllowNotification = json['isAllowNotification'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isSubscribed = json['isSubscribed'];
    iV = json['__v'];
    rating = json['rating'] != null ? json['rating'].toDouble() : 0.0;
    dob = json['dob'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['_id'] = sId;
    data['userName'] = userName;
    data['phone'] = phone;
    data['email'] = email;
    data['points'] = points;
    data['walletBalance'] = walletBalance;
    data['imageLink'] = imageLink;
    data['imagePath'] = imagePath;
    data['gender'] = gender;
    if (fcmTokens != null) {
      // data['fcmTokens'] = fcmTokens!.map((v) => v.toJson()).toList();
    }
    data['isDeleted'] = isDeleted;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['isSubscribed'] = isSubscribed;
    data['__v'] = iV;
    data['rating'] = rating;
    data['dob'] = dob;
    return data;
  }
}

class Location {
  String? country;
  double? latitude;
  double? longitude;
  String? streetName;
  String? subAdministrativeArea;
  String? city;

  Location({this.country, this.latitude, this.longitude, this.streetName, this.subAdministrativeArea, this.city});

  Location.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    latitude = json['latitude'].toDouble();
    longitude = json['longitude'].toDouble();
    streetName = json['streetName'];
    subAdministrativeArea = json['subAdministrativeArea'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country'] = country;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['streetName'] = streetName;
    data['subAdministrativeArea'] = subAdministrativeArea;
    data['city'] = city;
    return data;
  }
}
