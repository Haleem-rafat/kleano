class ErrorModel {
  String? ar;
  String? en;

  ErrorModel({this.ar, this.en});

  ErrorModel.fromJson(Map<String, dynamic> json) {
    ar = json['ar'];
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['ar'] = ar;
    data['en'] = en;
    return data;
  }

  String getErrorMessage(String languageCode) {
    return languageCode == 'en' ? en ?? '' : ar ?? '';
  }
}
