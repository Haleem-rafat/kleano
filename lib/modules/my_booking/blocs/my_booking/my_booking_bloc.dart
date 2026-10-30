import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/utilis/enums.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/data/repo/my_booking_repo.dart';
import 'package:thewasher/modules/my_booking/data/responses/my_booking_response.dart';
import 'package:thewasher/responses/base_response.dart';

part 'my_booking_event.dart';
part 'my_booking_state.dart';

class MyBookingBloc extends Bloc<MyBookingEvent, MyBookingState> {
  int pageNumber = 1;
  int pageTotalCount = 0;
  int totalItems = 0;

  MyBookingBloc() : super(const MyBookingState()) {
    on<FetchMyBookingActive>(_handleFetchMyBookingActive);
    on<MyBookingActivePerPage>(_handleMyBookingActivePerPage);
    on<FetchMyBookingHistory>(_handleFetchMyBookingHistory);
    on<MyBookingHistoryPerPage>(_handleMyBookingHistoryPerPage);
    on<FetchMyBookingScheduled>(_handleFetchMyBookingScheduled);
    on<MyBookingScheduledPerPage>(_handleMyBookingScheduledPerPage);
  }

  Future<void> _fetchBookings({
    required Emitter<MyBookingState> emit,
    required String status,
    required bool isRefresh,
    required List<OrderModel> list,
    required Function(List<OrderModel>) onSuccess,
  }) async {
    try {
      if (isRefresh) {
        final newState = state.copyWith(myBookingStatus: RequestStatus.loading);
        emit(newState);
      }
      final mutableList = List<OrderModel>.from(list);

      mutableList.clear();
      pageNumber = 1;
      pageTotalCount = 0;

      final MyBookingResponse? response =
          await MyBookingRepo.userViewAllMyBooking(
        pageNumber: pageNumber,
        status: status,
      );

      if (response!.success) {
        pageNumber++;
        pageTotalCount = response.results!.totalPages != null
            ? response.results!.totalPages!
            : 0;
        totalItems = response.results!.totalItems != null
            ? response.results!.totalItems!
            : 0;
        response.results!.data != null
            ? mutableList.addAll(response.results!.data!)
            : mutableList;
        onSuccess(mutableList);
        final newState = state.copyWith(myBookingStatus: RequestStatus.success);
        emit(newState);
        print('Transitioning to state: $newState');
      } else {
        final errorModel =
            ErrorModel.fromJson(jsonDecode(response.message.toString()));
        final newState = state.copyWith(
            myBookingStatus: RequestStatus.failure, error: errorModel);
        emit(newState);
        print('Transitioning to state: $newState');
      }
    } on DioError catch (e) {
      _handleDioError(emit, e);
    } catch (e) {
      final errorModel = ErrorModel(en: e.toString());
      final newState = state.copyWith(
          myBookingStatus: RequestStatus.failure, error: errorModel);
      emit(newState);
      print(
          'Transitioning to state: $newState'); // Log the transition to the failure state
    }
  }

  // Handle Dio errors
  void _handleDioError(Emitter<MyBookingState> emit, DioError e) {
    if (e.message!.contains('SocketException')) {
      emit(state.copyWith(myBookingStatus: RequestStatus.connectionError));
    } else {
      emit(state.copyWith(
          myBookingStatus: RequestStatus.failure,
          error: ErrorModel(en: e.message, ar: e.message)));
    }
  }

  Future<void> _handleFetchMyBookingActive(
      FetchMyBookingActive event, Emitter<MyBookingState> emit) async {
    await _fetchBookings(
      emit: emit,
      status: AppConstants.active,
      isRefresh: event.isRefresh == true ? true : false,
      list: state.activeList,
      onSuccess: (data) => emit(state.copyWith(
          myBookingStatus: RequestStatus.success, activeList: data)),
    );
  }

  Future<void> _handleMyBookingActivePerPage(
      MyBookingActivePerPage event, Emitter<MyBookingState> emit) async {
    await _fetchPerPage(
      emit: emit,
      status: AppConstants.active,
      list: state.activeList,
      onSuccess: (data) => emit(state.copyWith(
          myBookingStatus: RequestStatus.success, activeList: data)),
    );
  }

  Future<void> _handleFetchMyBookingHistory(
      FetchMyBookingHistory event, Emitter<MyBookingState> emit) async {
    await _fetchBookings(
      emit: emit,
      status: AppConstants.myBookingHistory,
      isRefresh: event.isRefresh!,
      list: state.historyList,
      onSuccess: (data) => emit(state.copyWith(
          myBookingStatus: RequestStatus.success, historyList: data)),
    );
  }

  Future<void> _handleMyBookingHistoryPerPage(
      MyBookingHistoryPerPage event, Emitter<MyBookingState> emit) async {
    await _fetchPerPage(
      emit: emit,
      status: AppConstants.myBookingHistory,
      list: state.historyList,
      onSuccess: (data) => emit(state.copyWith(
          myBookingStatus: RequestStatus.success, historyList: data)),
    );
  }

  Future<void> _handleFetchMyBookingScheduled(
      FetchMyBookingScheduled event, Emitter<MyBookingState> emit) async {
    await _fetchBookings(
      emit: emit,
      status: AppConstants.myBookingScheduled,
      isRefresh: event.isRefresh!,
      list: state.scheduledList,
      onSuccess: (data) => emit(state.copyWith(
          myBookingStatus: RequestStatus.success, scheduledList: data)),
    );
  }

  Future<void> _handleMyBookingScheduledPerPage(
      MyBookingScheduledPerPage event, Emitter<MyBookingState> emit) async {
    await _fetchPerPage(
      emit: emit,
      status: AppConstants.myBookingScheduled,
      list: state.scheduledList,
      onSuccess: (data) => emit(state.copyWith(
          myBookingStatus: RequestStatus.success, scheduledList: data)),
    );
  }

  // Pagination logic
  Future<void> _fetchPerPage({
    required Emitter<MyBookingState> emit,
    required String status,
    required List<OrderModel> list,
    required Function(List<OrderModel>) onSuccess,
  }) async {
    if (pageNumber > pageTotalCount) {
      emit(state.copyWith(myBookingStatus: RequestStatus.success));
      return;
    }
    // if (pageNumber <= pageTotalCount) {
    try {
      emit(state.copyWith(myBookingStatus: RequestStatus.perPageLoading));
      final MyBookingResponse? response =
          await MyBookingRepo.userViewAllMyBooking(
        pageNumber: pageNumber,
        status: status,
      );
      if (response!.success) {
        pageNumber++;
        pageTotalCount = response.results!.totalPages!;
        list.addAll(response.results!.data!);
        onSuccess(list);
        emit(state.copyWith(myBookingStatus: RequestStatus.success));
      } else {
        emit(state.copyWith(
            myBookingStatus: RequestStatus.failure,
            error: response.errorModel));
      }
    } on DioError catch (e) {
      _handleDioError(emit, e);
    } catch (e) {
      emit(state.copyWith(
          myBookingStatus: RequestStatus.failure,
          error: ErrorModel(en: e.toString(), ar: e.toString())));
    }
    // } else {
    //   emit(state.copyWith(myBookingStatus: RequestStatus.success));
    // }
  }
}
