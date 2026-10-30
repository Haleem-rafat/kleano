import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:thewhsherbiker/modules/order/data/repo/order_repo.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  int starsNum = 0;
  OrderBloc() : super(OrderInitial()) {
    on<BikerRating>((BikerRating event, Emitter<OrderState> emit) async {
      try {
        print("Biker Rating");
        emit(OrderRatingLoading());
        final bool response = await OrderRepo.bikerRating(
          event.starsNum,
          event.orderId,
        );
        if(response){
          emit(OrderRatingSuccess());
        }else{
          print("kkkk1");
          emit(OrderRatingFailed(error: "Error try again later"));
        }
      } catch (e) {
        print("kkkk2 ${e.toString()}");
        emit(OrderRatingFailed(error: e.toString()));
      }
    });
  }
}
