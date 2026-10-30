class Error {
  String message;
  String? field;

  Error({required this.message, this.field});

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      message: json['message'],
      field: json['field'],
    );
  }
}
