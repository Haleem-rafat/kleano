part of 'my_booking_bloc.dart';

class MyBookingState extends Equatable {
  final RequestStatus myBookingStatus;
  final ErrorModel? error;
  final List<OrderModel> activeList;
  final List<OrderModel> historyList;
  final List<OrderModel> scheduledList;

  const MyBookingState({
    this.myBookingStatus = RequestStatus.initial,
    this.error,
    this.activeList = const <OrderModel>[],
    this.historyList = const <OrderModel>[],
    this.scheduledList = const <OrderModel>[],
  });

  MyBookingState copyWith({
    RequestStatus? myBookingStatus,
    ErrorModel? error,
    List<OrderModel>? activeList,
    List<OrderModel>? historyList,
    List<OrderModel>? scheduledList,
  }) {
    return MyBookingState(
      myBookingStatus: myBookingStatus ?? this.myBookingStatus,
      error: error ?? this.error,
      activeList: activeList ?? this.activeList,
      historyList: historyList ?? this.historyList,
      scheduledList: scheduledList ?? this.scheduledList,
    );
  }

  @override
  List<Object?> get props => [
        myBookingStatus,
        error,
        activeList,
        historyList,
        scheduledList,
      ];
}
