class AddressModel {
  String? sId;
  double? latitude;
  double? longitude;
  String? streetName;
  String? subAdministrativeArea;
  String? country;
  String? cityId;
  String? areaId;
  bool? isSaved;
  bool? isDefault;
  String? user;
  String? createdAt;
  String? updatedAt;
  String? type;
  int? iV;
  String? savedName;

  AddressModel({
    this.sId,
    this.latitude,
    this.longitude,
    this.streetName,
    this.subAdministrativeArea,
    this.country,
    this.cityId,
    this.areaId,
    this.isSaved,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.type,
    this.iV,
    this.savedName,
    this.isDefault,
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    streetName = json['streetName'];
    subAdministrativeArea = json['subAdministrativeArea'];
    country = json['country'];
    cityId = json['city'];
    areaId = json['area'];
    isSaved = json['isSaved'];
    user = json['user'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    type = json['type'];
    iV = json['__v'];
    savedName = json['savedName'] ?? "";
    isDefault = json['isDefault'];
  }
}
