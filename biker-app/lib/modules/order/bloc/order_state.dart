part of 'order_bloc.dart';

@immutable
abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderRatingLoading extends OrderState {}
class OrderRatingSuccess extends OrderState {}
class OrderRatingFailed extends OrderState {
  final String error;

  OrderRatingFailed({required this.error});
}
