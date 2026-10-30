class CarBrand {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? logoUrl;

  CarBrand({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.logoUrl,
  });

  factory CarBrand.fromJson(Map<String, dynamic> json) {
    return CarBrand(
      id: json['_id'] as String,
      nameAr: json['brand']['ar'] as String,
      nameEn: json['brand']['en'] as String,
      logoUrl: json['brand']['logoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'brand': {
        'ar': nameAr,
        'en': nameEn,
        'logoUrl': logoUrl,
      },
    };
  }
}
