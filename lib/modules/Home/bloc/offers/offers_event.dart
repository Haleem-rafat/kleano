part of 'offers_bloc.dart';

@immutable
abstract class OffersEvent {}

class GetOffers extends OffersEvent {}

class GetServices extends OffersEvent {
  double lat;
  double lng;
  String country;
  String? type;

  GetServices({
    required this.lat,
    required this.lng,
    required this.country,
    this.type,
  });
}

class GetAddOns extends OffersEvent {
  double lat;
  double lng;
  String country;

  GetAddOns({
    required this.lat,
    required this.lng,
    required this.country,
  });
}

class AddServiceCart extends OffersEvent {
  final ServiceModel service;
  final int? selectedMainServiceIndex;

  AddServiceCart({required this.service, this.selectedMainServiceIndex});
}

class DeleteServiceCart extends OffersEvent {
  int index;
  ServiceModel service;

  DeleteServiceCart({required this.index, required this.service});
}

class AddExtraCart extends OffersEvent {
  AddOnsModel extra;
  AddExtraCart({required this.extra});
}

class DeleteExtraCart extends OffersEvent {
  int index;
  AddOnsModel extra;

  DeleteExtraCart({required this.index, required this.extra});
}

class ClearCart extends OffersEvent {}

class ClearAllSelectedServices extends OffersEvent {}

class GetGuestServices extends OffersEvent {
  double lat;
  double lng;
  String country;

  GetGuestServices({
    required this.lat,
    required this.lng,
    required this.country,
  });
}

class GetGuestAddOns extends OffersEvent {
  double lat;
  double lng;
  String country;

  GetGuestAddOns({
    required this.lat,
    required this.lng,
    required this.country,
  });
}
