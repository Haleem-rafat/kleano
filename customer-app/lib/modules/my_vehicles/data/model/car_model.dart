import 'package:equatable/equatable.dart';

class CarBrandsModel extends Equatable {
  final String id;
  final String name;

  const CarBrandsModel({
    required this.id,
    required this.name,
  });

  factory CarBrandsModel.fromJson(Map<String, dynamic> json) {
    return CarBrandsModel(
      id: json['_id'],
      name: json['brand'], // Ensure this is mapped correctly
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'brand': name,
    };
  }

  @override
  String toString() {
    return name;
  }

  @override
  List<Object> get props => [
        id,
        name,
      ];
}
