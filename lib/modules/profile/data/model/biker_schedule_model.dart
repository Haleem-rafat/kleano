class BikerScheduleModel {
  final String? sId;
  final String? biker;
  final List<Shift> shifts;
  final List<String> weekends;
  final String? createdAt;
  final String? updatedAt;
  final int? iV;

  BikerScheduleModel({
    this.sId,
    this.biker,
    required this.shifts,
    required this.weekends,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  factory BikerScheduleModel.fromJson(Map<String, dynamic> json) {
    return BikerScheduleModel(
      sId: json['_id'],
      biker: json['biker'],
      shifts: (json['shifts'] as List<dynamic>?)
              ?.map((shift) => Shift.fromJson(shift))
              .toList() ??
          [],
      weekends: (json['weekends'] as List<dynamic>?)
              ?.map((day) => day.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'biker': biker,
      'shifts': shifts.map((shift) => shift.toJson()).toList(),
      'weekends': weekends,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': iV,
    };
  }
}

class Shift {
  final String timeSlot;
  final City city;
  final Area area;
  final String day;
  final int priorityLevel;

  Shift({
    required this.timeSlot,
    required this.city,
    required this.area,
    required this.day,
    required this.priorityLevel,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      timeSlot: json['timeSlot'] ?? '',
      city: City.fromJson(json['city'] ?? {}),
      area: Area.fromJson(json['area'] ?? {}),
      day: json['day'] ?? '',
      priorityLevel: json['priorityLevel'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeSlot': timeSlot,
      'city': city.toJson(),
      'area': area.toJson(),
      'day': day,
      'priorityLevel': priorityLevel,
    };
  }
}

class City {
  final String? sId;
  final Name? name;

  City({
    this.sId,
    this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      sId: json['_id'],
      name: json['name'] != null ? Name.fromJson(json['name']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name?.toJson(),
    };
  }
}

class Area {
  final String? sId;
  final Name? name;

  Area({
    this.sId,
    this.name,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      sId: json['_id'],
      name: json['name'] != null ? Name.fromJson(json['name']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name?.toJson(),
    };
  }
}

class Name {
  final String? ar;
  final String? en;

  Name({
    this.ar,
    this.en,
  });

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      ar: json['ar'],
      en: json['en'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ar': ar,
      'en': en,
    };
  }
}
