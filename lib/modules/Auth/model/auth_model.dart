class AuthModel {
  final Location location;
  final String id;
  final String userName;
  final String phone;
  final String? email;
  final bool isSuspended;
  final bool isDeleted;
  final num points;
  final num walletBalance;
  final String language;
  final bool isAllowNotification;
  final double rating;
  final String createdAt;
  final String updatedAt;
  final int v;
  final String accessToken;
  final String refreshToken;

  AuthModel({
    required this.location,
    required this.id,
    required this.userName,
    required this.phone,
    required this.email,
    required this.isSuspended,
    required this.isDeleted,
    required this.points,
    required this.walletBalance,
    required this.language,
    required this.isAllowNotification,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      location: Location.fromJson(json['location']),
      id: json['_id'],
      userName: json['userName'],
      phone: json['phone'],
      email: json['email'] ?? "",
      isSuspended: json['isSuspended'],
      isDeleted: json['isDeleted'],
      points: json['points'],
      walletBalance: json['walletBalance'],
      language: json['language'],
      isAllowNotification: json['isAllowNotification'],
      rating: (json['rating'] as num).toDouble(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}

class Location {
  final double latitude;
  final double longitude;
  final String streetName;
  final String subAdministrativeArea;
  final String country;

  Location({
    required this.latitude,
    required this.longitude,
    required this.streetName,
    required this.subAdministrativeArea,
    required this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      streetName: json['streetName'],
      subAdministrativeArea: json['subAdministrativeArea'],
      country: json['country'],
    );
  }
}
