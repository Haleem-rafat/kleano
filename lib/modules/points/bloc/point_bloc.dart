import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/modules/points/data/models/apply_points_model.dart';
import 'package:thewasher/modules/points/data/models/point_model.dart';
import 'package:thewasher/modules/points/data/repo/point_repo.dart';
import 'package:thewasher/responses/base_response.dart';
import 'package:thewasher/responses/general_response.dart';

part 'point_event.dart';
part 'point_state.dart';

class PointBloc extends Bloc<PointEvent, PointState> {
  PointModel pointResponse = PointModel();
  PointBloc() : super(PointInitial()) {
    on<PointEvent>((event, emit) async {
      if (event is GetUserPoints) {
        try {
          emit(PointLoading());
          final GenericResponse<PointModel> response =
              await PointRepo.getUserPoints();
          if (response.success) {
            pointResponse = response.result!;
            emit(PointLoaded(pointResponse: pointResponse));
          } else {
            emit(PointFailed(error: response.error!.first.message));
          }
        } catch (e) {
          emit(PointFailed(error: e.toString()));
        }
      }
    });
    on<ApplyPoints>((event, emit) async {
      try {
        emit(ApplyPointsLoading());
        final GenericResponse<ApplyPoint> response =
            await PointRepo.applyPoints(
          orderId: event.orderId,
        );
        if (response.success && response.result != null) {
          emit(ApplyPointsSuccess(applyPointModel: response.result!));
        } else {
          emit(ApplyPointsFailed(
            errorModel: response.errorModel!,
            error: response.error!.first.message,
          ));
        }
      } catch (e) {
        emit(ApplyPointsFailed(error: e.toString()));
      }
    });
  }
}
