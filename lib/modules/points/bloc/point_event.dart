part of 'point_bloc.dart';

@immutable
abstract class PointEvent {}

class GetUserPoints extends PointEvent {}

class ApplyPoints extends PointEvent {
  final String orderId;
  ApplyPoints({
    required this.orderId,
  });
}
