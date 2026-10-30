class AuthModel {
  bool? success;
  Data? data;

  AuthModel({this.success, this.data});

  AuthModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? userName;
  String? phone;
  String? email;
  List<String>? fcmTokens;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? accessToken;
  String? refreshToken;

  Data(
      {this.userName,
      this.phone,
      this.email,
      this.fcmTokens,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.accessToken,
      this.refreshToken});

  Data.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    phone = json['phone'];
    email = json['email'];
    if (json['fcmTokens'] != null) {
      fcmTokens = <String>[];
      json['fcmTokens'].forEach((v) {
        // fcmTokens!.add(fcmTokens);
      });
    }
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['phone'] = phone;
    data['email'] = email;
    if (fcmTokens != null) {
      data['fcmTokens'] = fcmTokens!.map((dynamic v) => v.toJson()).toList();
    }
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['access_token'] = accessToken;
    data['refresh_token'] = refreshToken;
    return data;
  }
}
