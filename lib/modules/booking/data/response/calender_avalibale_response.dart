class CalenderAvalibleResponse {
  final String timeSlot;
  final String? day;
  final int? availableBikersCount;
  final bool isAvailable;

  CalenderAvalibleResponse({
    required this.timeSlot,
    this.day,
    this.availableBikersCount,
    required this.isAvailable,
  });

  factory CalenderAvalibleResponse.fromJson(Map<String, dynamic> json) {
    return CalenderAvalibleResponse(
      timeSlot: json['timeSlot'],
      day: json['day'],
      availableBikersCount: json['availableBikersCount'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

class CityInfo {
  final String id;
  final LocalizedName name;

  CityInfo({
    required this.id,
    required this.name,
  });

  factory CityInfo.fromJson(Map<String, dynamic> json) {
    return CityInfo(
      id: json['_id'],
      name: LocalizedName.fromJson(json['name']),
    );
  }
}

class AreaInfo {
  final String id;
  final LocalizedName name;
  final double? latitude;
  final double? longitude;

  AreaInfo({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
  });

  factory AreaInfo.fromJson(Map<String, dynamic> json) {
    return AreaInfo(
      id: json['_id'],
      name: LocalizedName.fromJson(json['name']),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

class LocalizedName {
  final String ar;
  final String en;

  LocalizedName({
    required this.ar,
    required this.en,
  });

  factory LocalizedName.fromJson(Map<String, dynamic> json) {
    return LocalizedName(
      ar: json['ar'] ?? '',
      en: json['en'] ?? '',
    );
  }
}
