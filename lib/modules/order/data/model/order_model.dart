class OrderModel {
  String? sId;
  User? user;
  List<WashingServices>? washingServices;
  List<AddOns>? addOns;
  Vehicle? vehicle;
  OrderLocation? location;
  DateTime? startTime;
  int? totalDuration;
  String? status;
  String? description;
  String? type;
  String? paymentType;
  num? totalPrice;
  num? discount;
  num? totalPay;
  DateTime? createdAt;
  DateTime? bookingDate;
  DateTime? updatedAt;
  int? iV;
  bool? isAssigned;
  int? ratingOfBiker;
  int? ratingOfUser;
  String? afterWashImage;
  String? beforeWashImage;
  bool? isCarFreshened;

  OrderModel({
    this.sId,
    this.user,
    this.washingServices,
    this.addOns,
    this.vehicle,
    this.location,
    this.startTime,
    this.totalDuration,
    this.status,
    this.description,
    this.type,
    this.paymentType,
    this.totalPrice,
    this.discount,
    this.totalPay,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.isAssigned,
    this.ratingOfUser,
    this.ratingOfBiker,
    this.afterWashImage,
    this.beforeWashImage,
    this.isCarFreshened,
    this.bookingDate,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['washingServices'] != null) {
      washingServices = <WashingServices>[];
      json['washingServices'].forEach((v) {
        washingServices!.add(WashingServices.fromJson(v));
      });
    }
    if (json['addOns'] != null) {
      addOns = <AddOns>[];
      json['addOns'].forEach((v) {
        addOns!.add(AddOns.fromJson(v));
      });
    }
    vehicle =
        json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null;
    location = json['location'] != null
        ? OrderLocation.fromJson(json['location'])
        : null;
    startTime = DateTime.parse(json['startTime']).toLocal();
    totalDuration = json['totalDuration'];
    status = json['status'];
    description = json['description'];
    type = json['type'];
    paymentType = json['paymentType'];
    totalPrice = json['totalPrice'];
    discount = json['discount'];
    totalPay = json['totalPay'];
    createdAt = DateTime.parse(json['createdAt']).toLocal();
    updatedAt = DateTime.parse(json['updatedAt']).toLocal();
    iV = json['__v'];
    isAssigned = json['isAssigned'] ?? false;
    ratingOfBiker = json['ratingOfBiker'] ?? 0;
    ratingOfUser = json['ratingOfUser'] ?? 0;
    afterWashImage = json['carAfterWashLink'];
    beforeWashImage = json['carBeforeWashLink'];
    isCarFreshened = json['isCarFreshened'];
    bookingDate = DateTime.parse(json['bookingDate']).toLocal();
  }
}

class User {
  String? sId;
  String? userName;
  String? phone;
  String? imageLink;

  User({this.sId, this.userName, this.phone, this.imageLink});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userName = json['userName'];
    phone = json['phone'];
    imageLink = json['imageLink'];
  }
}

class WashingServices {
  String? sId;
  dynamic _name;
  dynamic _description;
  int? duration;
  int? price;
  int? pointsToPay;
  IconOrder? iconWashingServices;

  WashingServices({
    this.sId,
    String? name,
    MultilingualName? nameMultilingual,
    List<String>? description,
    MultilingualDescription? descriptionMultilingual,
    this.duration,
    this.price,
    this.pointsToPay,
    this.iconWashingServices,
  })  : _name = nameMultilingual ?? name,
        _description = descriptionMultilingual ?? description;

  String? get name {
    if (_name is String) {
      return _name as String;
    } else if (_name is MultilingualName) {
      return (_name as MultilingualName).en;
    }
    return null;
  }

  MultilingualName? get nameMultilingual =>
      _name is MultilingualName ? _name as MultilingualName : null;

  String? getLocalizedName(String languageCode) {
    if (_name is String) {
      return _name as String;
    } else if (_name is MultilingualName) {
      final multilingualName = _name as MultilingualName;
      if (languageCode == 'ar') {
        return multilingualName.ar;
      } else {
        return multilingualName.en;
      }
    }
    return null;
  }

  List<String>? get description {
    if (_description is List<String>) {
      return _description as List<String>?;
    } else if (_description is MultilingualDescription) {
      return (_description as MultilingualDescription).en;
    }
    return null;
  }

  MultilingualDescription? get descriptionMultilingual =>
      _description is MultilingualDescription
          ? _description as MultilingualDescription
          : null;

  List<String>? getLocalizedDescription(String languageCode) {
    if (_description is List<String>) {
      final List<String> descriptions = _description as List<String>;
      // Parse strings that contain both languages (e.g., "en: ... ar: ...")
      return descriptions.map((String desc) {
        return _extractLanguageFromString(desc, languageCode);
      }).toList();
    } else if (_description is MultilingualDescription) {
      final multilingualDescription = _description as MultilingualDescription;
      if (languageCode == 'ar') {
        return multilingualDescription.ar;
      } else {
        return multilingualDescription.en;
      }
    }
    return null;
  }

  String _extractLanguageFromString(String text, String languageCode) {
    // Check if the string contains multilingual format
    // Handle formats like:
    // - "en: English text, ar: Arabic text"
    // - "en: English text ar: Arabic text"
    // - "en: English text Arabic text" (no ar: prefix)

    final arabicCharPattern = RegExp(
        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    final hasArabic = arabicCharPattern.hasMatch(text);

    if (languageCode == 'ar') {
      // Extract Arabic part
      if (hasArabic) {
        // Try pattern "ar: ..."
        final arPattern = RegExp(r'ar:\s*(.+?)$', dotAll: true);
        final arMatch = arPattern.firstMatch(text);
        if (arMatch != null && arMatch.group(1) != null) {
          return arMatch.group(1)!.trim();
        }

        // Find where Arabic characters start
        final arabicStartMatch = arabicCharPattern.firstMatch(text);
        if (arabicStartMatch != null) {
          final arabicStart = arabicStartMatch.start;
          // Check if there's "en:" before Arabic, if so extract only Arabic part
          final beforeArabic = text.substring(0, arabicStart);
          if (beforeArabic.toLowerCase().contains('en:')) {
            return text.substring(arabicStart).trim();
          }
        }
      }
      // If no Arabic found or extraction failed, return empty or fallback
      return '';
    } else {
      // Extract English part
      // Try pattern "en: ..."
      final enPattern =
          RegExp(r'en:\s*(.+?)(?:\s*,\s*ar:|\s*ar:|$)', dotAll: true);
      final enMatch = enPattern.firstMatch(text);
      if (enMatch != null && enMatch.group(1) != null) {
        String englishText = enMatch.group(1)!.trim();
        // Remove any Arabic characters that might be mixed in
        if (hasArabic) {
          final arabicStartMatch = arabicCharPattern.firstMatch(englishText);
          if (arabicStartMatch != null) {
            englishText =
                englishText.substring(0, arabicStartMatch.start).trim();
          }
        }
        return englishText;
      }

      // If no "en:" prefix, check if text starts with English (non-Arabic)
      if (hasArabic) {
        final arabicStartMatch = arabicCharPattern.firstMatch(text);
        if (arabicStartMatch != null && arabicStartMatch.start > 0) {
          return text.substring(0, arabicStartMatch.start).trim();
        }
      } else {
        // No Arabic, return full text
        return text.trim();
      }

      // Fallback
      return text.trim();
    }
  }

  WashingServices.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['name'] != null) {
      if (json['name'] is String) {
        _name = json['name'] as String;
      } else if (json['name'] is Map<String, dynamic>) {
        _name = MultilingualName.fromJson(json['name'] as Map<String, dynamic>);
      }
    }
    if (json['description'] != null) {
      if (json['description'] is List) {
        _description = (json['description'] as List)
            .map((e) => e is String ? e : e.toString())
            .toList()
            .cast<String>();
      } else if (json['description'] is Map<String, dynamic>) {
        _description = MultilingualDescription.fromJson(
            json['description'] as Map<String, dynamic>);
      }
    }
    duration = json['duration'];
    price = json['price'];
    pointsToPay = json['pointsToPay'];
    iconWashingServices =
        json['icon'] != null ? IconOrder.fromJson(json['icon']) : null;
  }
}

class MultilingualName {
  String? en;
  String? ar;

  MultilingualName({this.en, this.ar});

  MultilingualName.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en'] = en;
    data['ar'] = ar;
    return data;
  }
}

class MultilingualDescription {
  List<String>? en;
  List<String>? ar;

  MultilingualDescription({this.en, this.ar});

  MultilingualDescription.fromJson(Map<String, dynamic> json) {
    if (json['en'] != null) {
      en =
          (json['en'] as List).map((e) => e.toString()).toList().cast<String>();
    }
    if (json['ar'] != null) {
      ar =
          (json['ar'] as List).map((e) => e.toString()).toList().cast<String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en'] = en;
    data['ar'] = ar;
    return data;
  }
}

class IconOrder {
  String? sId;
  String? iconPath;
  String? iconLink;

  IconOrder({
    this.sId,
    this.iconPath,
    this.iconLink,
  });

  IconOrder.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    iconPath = json['iconPath'];
    iconLink = json['iconLink'];
  }
}

class AddOns {
  String? sId;
  dynamic _name;
  int? price;
  IconOrder? iconAddons;

  AddOns({
    this.sId,
    String? name,
    MultilingualName? nameMultilingual,
    this.price,
    this.iconAddons,
  }) : _name = nameMultilingual ?? name;

  String? get name {
    if (_name is String) {
      return _name as String;
    } else if (_name is MultilingualName) {
      return (_name as MultilingualName).en;
    }
    return null;
  }

  MultilingualName? get nameMultilingual =>
      _name is MultilingualName ? _name as MultilingualName : null;

  String? getLocalizedName(String languageCode) {
    if (_name is String) {
      return _name as String;
    } else if (_name is MultilingualName) {
      final multilingualName = _name as MultilingualName;
      if (languageCode == 'ar') {
        return multilingualName.ar;
      } else {
        return multilingualName.en;
      }
    }
    return null;
  }

  AddOns.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['name'] != null) {
      if (json['name'] is String) {
        _name = json['name'] as String;
      } else if (json['name'] is Map<String, dynamic>) {
        _name = MultilingualName.fromJson(json['name'] as Map<String, dynamic>);
      }
    }
    price = json['price'];
    iconAddons = json['icon'] != null ? IconOrder.fromJson(json['icon']) : null;
  }
}

class Vehicle {
  String? sId;
  String? type;
  String? brand;
  String? model;
  String? plateNumber;
  String? color;
  String? imageLink;

  Vehicle({
    this.sId,
    this.type,
    this.brand,
    this.model,
    this.plateNumber,
    this.color,
    this.imageLink,
  });

  Vehicle.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    brand = json['brand'];
    model = json['model'];
    plateNumber = json['plateNumber'];
    color = json['color'];
    imageLink = json['imageLink'];
  }
}

class OrderLocation {
  String? sId;
  double? latitude;
  double? longitude;
  String? streetName;
  String? subAdministrativeArea;
  String? city;
  bool? isSaved;

  OrderLocation({
    this.sId,
    this.latitude,
    this.longitude,
    this.streetName,
    this.subAdministrativeArea,
    this.city,
    this.isSaved,
  });

  OrderLocation.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    streetName = json['streetName'];
    subAdministrativeArea = json['subAdministrativeArea'];
    // The backend sends either the id or the populated city object.
    final dynamic rawCity = json['city'];
    city = rawCity is Map ? rawCity['_id']?.toString() : rawCity?.toString();
    isSaved = json['isSaved'];
  }
}
