class VehiclesModel {
  String? sId;
  String? type;
  String? brand;
  String? model;
  String? plateNumber;
  String? color;
  String? user;
  String? createdAt;
  String? updatedAt;
  String? imageLink;

  VehiclesModel({
    this.sId,
    this.type,
    this.brand,
    this.model,
    this.plateNumber,
    this.color,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.imageLink,
  });

  VehiclesModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    brand = json['brand'];
    model = json['model'];
    plateNumber = json['plateNumber'];
    color = json['color'];
    user = json['user'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    imageLink = json['imageLink'] ?? "";
  }
}
