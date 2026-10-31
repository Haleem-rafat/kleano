part of 'plans_and_subscription_bloc.dart';

abstract class PlansAndSubscriptionState extends Equatable {
  const PlansAndSubscriptionState();

  @override
  List<Object> get props => [];
}

class PlansAndSubscriptionInitial extends PlansAndSubscriptionState {}

class PlansAndSubscriptionLoadingState extends PlansAndSubscriptionState {}

class GetPlansLoading extends PlansAndSubscriptionLoadingState {}

class GetPlansSuccess extends PlansAndSubscriptionState {
  final List<Plan> plans;
  const GetPlansSuccess({required this.plans});
}

class GetPlanFailed extends PlansAndSubscriptionState {
  final String error;
  const GetPlanFailed({required this.error});
}

class PlansAndSubscriptionConnectionError extends PlansAndSubscriptionState {}

class GetSubscriptionLoading extends PlansAndSubscriptionLoadingState {}

class PlansAndSubscriptioSuccessState extends PlansAndSubscriptionState {
  final List<Plan> allPlans;
  final Subscription subscription;
  const PlansAndSubscriptioSuccessState({
    required this.allPlans,
    required this.subscription,
  });
}

class GetSubscriptionSuccess extends PlansAndSubscriptionState {
  final Subscription subscription;
  const GetSubscriptionSuccess({required this.subscription});
}

class GetSubscriptionFailed extends PlansAndSubscriptionState {
  final String error;
  const GetSubscriptionFailed({required this.error});
}

class CreateSubscriptionLoading extends PlansAndSubscriptionState {}

class CreateSubscriptionSuccess extends PlansAndSubscriptionState {
  final String? subscriptionId;
  const CreateSubscriptionSuccess({required this.subscriptionId});
}

class CreateSubscriptionFailed extends PlansAndSubscriptionState {
  final ErrorModel? errorModel;
  final String? error;
  const CreateSubscriptionFailed({this.errorModel, this.error});
}

class PaySubscriptionLoading extends PlansAndSubscriptionState {}

class PaySubscriptionSuccess extends PlansAndSubscriptionState {
  final String? paymentUrl;
  const PaySubscriptionSuccess({required this.paymentUrl});
}

class PaySubscriptionFailed extends PlansAndSubscriptionState {
  final ErrorModel? errorModel;
  final String? error;
  const PaySubscriptionFailed({this.errorModel, this.error});
}

class SubscriptionByLocationLoading extends PlansAndSubscriptionLoadingState {}

class SubscriptioByLocationSuccessState extends PlansAndSubscriptionState {
  final Subscription subscription;
  final String message;
  const SubscriptioByLocationSuccessState({
    required this.subscription,
    required this.message,
  });
}

class SubscriptionByLocationFailed extends PlansAndSubscriptionLoadingState {
  final String error;

  SubscriptionByLocationFailed({required this.error});
}
