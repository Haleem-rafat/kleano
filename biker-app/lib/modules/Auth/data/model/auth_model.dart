class AuthModel {
  String? sId;
  String? userName;
  String? phone;
  bool? isDeleted;
  String? city;
  String? nationalId;
  String? status;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? imageLink;
  String? imagePath;
  String? accessToken;
  String? refreshToken;

  AuthModel({
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
    this.accessToken,
    this.refreshToken,
  });

  AuthModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userName = json['userName'];
    phone = json['phone'];
    isDeleted = json['isDeleted'];
    city = json['city'];
    nationalId = json['nationalId'];
    status = json['status'];
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    imageLink = json['imageLink'];
    imagePath = json['imagePath'];
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
  }
}
