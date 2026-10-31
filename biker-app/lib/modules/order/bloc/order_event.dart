part of 'order_bloc.dart';

@immutable
abstract class OrderEvent {}


class BikerRating extends OrderEvent{
  final String orderId;
  final num starsNum;
  BikerRating({required this.orderId, required this.starsNum});
}
