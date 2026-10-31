class AcceptedOrderByBikerModel {
  bool? success;
  String? sId;
  String? status;
  Biker? biker;
  String? time;

  AcceptedOrderByBikerModel({
    this.success,
    this.sId,
    this.status,
    this.biker,
    this.time,
  });

  AcceptedOrderByBikerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    sId = json['_id'];
    status = json['status'];
    biker = json['biker'] != null ? Biker.fromJson(json['biker']) : null;
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['_id'] = sId;
    data['status'] = status;
    if (biker != null) {
      data['biker'] = biker!.toJson();
    }
    data['time'] = time;
    return data;
  }
}

class Biker {
  String? sId;
  String? userName;
  String? phone;
  String? imageLink;
  String? imagePath;
  double? rating;
  double? latitude;
  double? longitude;

  Biker({
    this.sId,
    this.userName,
    this.phone,
    this.imageLink,
    this.imagePath,
    this.rating,
    this.latitude,
    this.longitude,
  });

  Biker.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userName = json['userName'];
    phone = json['phone'];
    imageLink = json['imageLink'] ?? '';
    imagePath = json['imagePath'];
    rating = json['rating'].toDouble() ?? 0.0;
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userName'] = userName;
    data['phone'] = phone;
    data['imageLink'] = imageLink;
    data['imagePath'] = imagePath;
    data['rating'] = rating;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    return data;
  }
}
