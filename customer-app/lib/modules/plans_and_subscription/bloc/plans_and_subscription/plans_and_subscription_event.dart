part of 'plans_and_subscription_bloc.dart';

abstract class PlansAndSubscriptionEvent {
  const PlansAndSubscriptionEvent();
}

class GetAllPlansForGuest extends PlansAndSubscriptionEvent {
  final double latitude;
  final double longitude;
  final String country;

  GetAllPlansForGuest({
    required this.latitude,
    required this.longitude,
    required this.country,
  });
}

class GetUserSubscription extends PlansAndSubscriptionEvent {}

class GetSubscriptionAndPlans extends PlansAndSubscriptionEvent {
  final double latitude;
  final double longitude;
  final String country;
  const GetSubscriptionAndPlans({
    required this.latitude,
    required this.longitude,
    required this.country,
  });
}

class CreateUserSubscription extends PlansAndSubscriptionEvent {
  final String planId;
  final String paymentType;
  CreateUserSubscription({
    required this.planId,
    required this.paymentType,
  });
}

class PaySubscription extends PlansAndSubscriptionEvent {
  final String subscriptionId;
  final PaymentDetailsRequest? paymentDetailsRequest;
  final String? applePayId;
  PaySubscription({
    required this.subscriptionId,
    this.applePayId,
     this.paymentDetailsRequest,
  });
}

class GetSubscriptionUserByLocation extends PlansAndSubscriptionEvent {
  final double latitude;
  final double longitude;
  final String country;
  const GetSubscriptionUserByLocation({
    required this.latitude,
    required this.longitude,
    required this.country,
  });
}
