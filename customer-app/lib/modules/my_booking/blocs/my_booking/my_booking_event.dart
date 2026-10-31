part of 'my_booking_bloc.dart';

class MyBookingEvent {}

class FetchMyBookingActive extends MyBookingEvent {
  final bool? isRefresh;
  FetchMyBookingActive({
    this.isRefresh = true,
  });
}

class MyBookingActivePerPage extends MyBookingEvent {}

class FetchMyBookingHistory extends MyBookingEvent {
  final bool? isRefresh;
  FetchMyBookingHistory({
    this.isRefresh = true,
  });
}

class MyBookingHistoryPerPage extends MyBookingEvent {}

class FetchMyBookingScheduled extends MyBookingEvent {
  final bool? isRefresh;
  FetchMyBookingScheduled({
    this.isRefresh = true,
  });
}

class MyBookingScheduledPerPage extends MyBookingEvent {}
