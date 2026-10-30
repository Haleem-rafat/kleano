import 'dart:io';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/modules/booking/data/models/payment_methods_request.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/plans_model.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/subscription_model.dart';
import 'package:thewasher/modules/plans_and_subscription/data/repo/plans_subscription_repo.dart';
import 'package:thewasher/modules/plans_and_subscription/data/responses/get_subscription_response.dart';
import 'package:thewasher/modules/plans_and_subscription/data/responses/plans_response.dart';
import 'package:thewasher/responses/base_response.dart';

part 'plans_and_subscription_event.dart';
part 'plans_and_subscription_state.dart';

class PlansAndSubscriptionBloc
    extends Bloc<PlansAndSubscriptionEvent, PlansAndSubscriptionState> {
  String message = '';
  Subscription subscription = Subscription();
  PlansAndSubscriptionBloc() : super(PlansAndSubscriptionInitial()) {
    on<GetAllPlansForGuest>((event, emit) async {
      try {
        emit(GetPlansLoading());
        PlansResponse response = await PlansAndSubscriptionRepo.getAllPlans(
          latitude: event.latitude,
          longitude: event.longitude,
          country: event.country,
        );

        if (response.success) {
          emit(GetPlansSuccess(plans: response.results!));
        } else {
          emit(GetPlanFailed(error: response.message));
        }
      } on DioException catch (e) {
        if (e.message!.contains('SocketException')) {
          emit(PlansAndSubscriptionConnectionError());
        } else {
          // emit(GetPlanFailed(error: e.message));
        }
      } catch (e) {
        if (e is SocketException) {
          emit(PlansAndSubscriptionConnectionError());
        } else {
          emit(GetPlanFailed(error: e.toString()));
        }
      }
    });

    on<GetSubscriptionAndPlans>((event, emit) async {
      try {
        emit(GetSubscriptionLoading());

        Subscription? subscription;
        List<Plan>? plans;

        SubscriptionResponse subscriptionResponse =
            await PlansAndSubscriptionRepo.getUserSubscription();

        PlansResponse plansResponse =
            await PlansAndSubscriptionRepo.getAllPlans(
          latitude: event.latitude,
          longitude: event.longitude,
          country: event.country,
        );
        if (subscriptionResponse.success) {
          subscription = subscriptionResponse.results!.data;
        }

        if (plansResponse.success) {
          plans = plansResponse.results!;
        }
        emit(PlansAndSubscriptioSuccessState(
            allPlans: plans ?? <Plan>[],
            subscription: subscriptionResponse.results!.data!));
      } on DioException catch (e) {
        if (e.message!.contains('SocketException')) {
          emit(PlansAndSubscriptionConnectionError());
        } else {
          // emit(GetSubscriptionFailed(error: e.message));
        }
      } catch (e) {
        if (e is SocketException) {
          emit(PlansAndSubscriptionConnectionError());
        } else {
          emit(GetSubscriptionFailed(error: e.toString()));
        }
      }
    });

    on<CreateUserSubscription>((event, emit) async {
      try {
        emit(CreateSubscriptionLoading());
        SubscriptionResponse response =
            await PlansAndSubscriptionRepo.createUserSubscription(
          planId: event.planId,
          paymentType: event.paymentType,
        );

        if (response.success) {
          emit(CreateSubscriptionSuccess(
              subscriptionId: response.results!.data!.sId ?? ''));
        } else {
          emit(CreateSubscriptionFailed(errorModel: response.errorModel!));
        }
      } on DioException catch (e) {
        if (e.message!.contains('SocketException')) {
          emit(PlansAndSubscriptionConnectionError());
        } else {
          emit(CreateSubscriptionFailed(error: e.message));
        }
      } catch (e) {
        if (e is SocketException) {
          emit(PlansAndSubscriptionConnectionError());
        } else {
          emit(CreateSubscriptionFailed(error: e.toString()));
        }
      }
    });
    on<PaySubscription>((event, emit) async {
      try {
        emit(PaySubscriptionLoading());
        final response = await PlansAndSubscriptionRepo.paySubscription(
          applePayId: event.applePayId,
          subscriptionId: event.subscriptionId,
          paymentDetailsRequest: event.paymentDetailsRequest,
        );

        if (response.success) {
          emit(PaySubscriptionSuccess(paymentUrl: response.result));
        } else {
          emit(PaySubscriptionFailed(errorModel: response.errorModel!));
        }
      } on DioException catch (e) {
        if (e.message!.contains('SocketException')) {
          emit(PlansAndSubscriptionConnectionError());
        } else {
          emit(PaySubscriptionFailed(error: e.message));
        }
      } catch (e) {
        if (e is SocketException) {
          emit(PlansAndSubscriptionConnectionError());
        } else {
          emit(PaySubscriptionFailed(error: e.toString()));
        }
      }
    });
    on<GetSubscriptionUserByLocation>((event, emit) async {
      // final String message;
      try {
        emit(SubscriptionByLocationLoading());
        SubscriptionResponse response =
            await PlansAndSubscriptionRepo.getSubscriptionByLocation(
          latitude: event.latitude,
          longitude: event.longitude,
          country: event.country,
        );
        if (response.success) {
          message = response.message!;
          subscription = response.results!.data!;
          emit(SubscriptioByLocationSuccessState(
              subscription: subscription, message: message));
        } else {
          emit(SubscriptionByLocationFailed(error: response.errorMessage));
        }
      } on DioException catch (e) {
        if (e.message!.contains('SocketException')) {
          emit(PlansAndSubscriptionConnectionError());
        } else {
          // emit(SubscriptionByLocationFailed(error: e.message));
        }
      } catch (e) {
        if (e is SocketException) {
          emit(PlansAndSubscriptionConnectionError());
        } else {
          emit(SubscriptionByLocationFailed(error: e.toString()));
        }
      }
    });
  }
}
