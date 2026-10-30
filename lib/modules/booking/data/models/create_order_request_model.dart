import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';

class CreateOrderRequest {
  final List<String>? washingServices;
  final List<String>? addOns;
  final String vehicleId;
  final LocationRequest locationRequest;
  final String? description;
  final String startTime;
  final String type;
  final String? subscriptionId;
  final double totalPrice;
  final String? paymentType;
  final String? bookingDate;
  final String? code;
  final bool isCarFreshened;
  final String userOS;
  final String? timeSlot;
  final num appliedPoints;

  CreateOrderRequest({
    this.washingServices,
    this.addOns,
    required this.vehicleId,
    required this.locationRequest,
    this.description,
    required this.startTime,
    required this.type,
    this.subscriptionId,
    required this.totalPrice,
    this.paymentType,
    required this.bookingDate,
    this.code,
    required this.isCarFreshened,
    required this.userOS,
    this.timeSlot,
    this.appliedPoints = 0,
  });
}

class LocationRequest {
  double? latitude;
  double? longitude;
  String? streetName, subAdministrativeArea, country;

  LocationRequest({
    this.latitude,
    this.longitude,
    this.streetName,
    this.subAdministrativeArea,
    this.country,
  });

  factory LocationRequest.fromJson(Map<String, dynamic> json) {
    return LocationRequest(
        latitude: blcoPosition.latitude,
        longitude: blcoPosition.longitude,
        streetName: blcoLocationName,
        subAdministrativeArea: blcoSubAdministrativeArea,
        country: blcoCountry);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('latitude', latitude);
    writeNotNull('longitude', longitude);
    writeNotNull('streetName', streetName);
    writeNotNull('subAdministrativeArea', subAdministrativeArea);
    writeNotNull('country', country);

    return val;
  }
}
