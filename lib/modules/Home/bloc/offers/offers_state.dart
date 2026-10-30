part of 'offers_bloc.dart';

@immutable
abstract class OffersState {}

class OffersInitial extends OffersState {}

class GetOffersLoading extends OffersState {}

class GetOffersSuccess extends OffersState {}

class GetOffersFailed extends OffersState {}

/////////////////////////////////////////////////////////
class GetServicesLoading extends OffersState {}

class GetServicesSuccess extends OffersState {
  final List<ServiceModel> servicesList;
  final List<ServiceModel> mainServices;
  final List<ServiceModel> extraServices;

  GetServicesSuccess(
      {required this.servicesList,
      required this.mainServices,
      required this.extraServices});
}

class EmptyServices extends OffersState {}

class GetServicesFailed extends OffersState {
  final String error;

  GetServicesFailed({required this.error});
}

/////////////////////////////////////////////////////////
class GetAddOnsLoading extends OffersState {}

class GetAddOnsSuccess extends OffersState {
  final List<AddOnsModel> addOnsList;

  GetAddOnsSuccess({required this.addOnsList});
}

class GetAddOnsFailed extends OffersState {
  final String error;

  GetAddOnsFailed({required this.error});
}

/////////////////////////////////////////////////////////
class AddServiceCartLoading extends OffersState {}

class AddServiceCartSuccess extends OffersState {}

class AddServiceCartFailed extends OffersState {
  final String error;

  AddServiceCartFailed({required this.error});
}

/////////////////////////////////////////////////////////
class DeleteServiceCartLoading extends OffersState {}

class DeleteServiceCartSuccess extends OffersState {}

class DeleteServiceCartFailed extends OffersState {
  final String error;

  DeleteServiceCartFailed({required this.error});
}

/////////////////////////////////////////////////////////
class AddExtraCartLoading extends OffersState {}

class AddExtraCartSuccess extends OffersState {}

class AddExtraCartFailed extends OffersState {
  final String error;

  AddExtraCartFailed({required this.error});
}

/////////////////////////////////////////////////////////
class DeleteExtraCartLoading extends OffersState {}

class DeleteExtraCartSuccess extends OffersState {}

class DeleteExtraCartFailed extends OffersState {
  final String error;

  DeleteExtraCartFailed({required this.error});
}

/////////////////////////////////////////////////////////
class ClearCartLoading extends OffersState {}

class ClearCartSuccess extends OffersState {}

class ClearCartFailed extends OffersState {
  final String error;

  ClearCartFailed({required this.error});
}

/////////////////////////////////////////////////////////
class ClearAllSelectedServicesLoading extends OffersState {}

class ClearAllSelectedServicesSuccess extends OffersState {}

class ClearAllSelectedServicesFailed extends OffersState {
  final String error;

  ClearAllSelectedServicesFailed({required this.error});
}

/////////////////////////////////////////////////////////
class GetGuestServicesLoading extends OffersState {}

class GetGuestServicesSuccess extends OffersState {
  final List<ServiceModel> servicesList;
  final List<ServiceModel> mainServices;
  final List<ServiceModel> extraServices;

  GetGuestServicesSuccess({
    required this.servicesList,
    required this.mainServices,
    required this.extraServices,
  });
}

class EmptyGuestServices extends OffersState {}

class GetGuestServicesFailed extends OffersState {
  final String error;

  GetGuestServicesFailed({required this.error});
}

/////////////////////////////////////////////////////////
class GetGuestAddOnsLoading extends OffersState {}

class GetGuestAddOnsSuccess extends OffersState {
  final List<AddOnsModel> addOnsList;

  GetGuestAddOnsSuccess({required this.addOnsList});
}

class GetGuestAddOnsFailed extends OffersState {
  final String error;

  GetGuestAddOnsFailed({required this.error});
}
