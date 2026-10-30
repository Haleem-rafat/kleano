import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:thewasher/modules/Home/data/model/banner_model.dart';
import 'package:thewasher/repository/home_repo.dart';

part 'banner_event.dart';
part 'banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  BannerBloc() : super(const BannerState(status: BannerStatus.initial)) {
    on<GetBanners>(_getBanners);
  }
  Future<void> _getBanners(
    GetBanners event,
    Emitter<BannerState> emit,
  ) async {
    emit(state.copyWith(status: BannerStatus.loading));
    try {
      final response = await HomeRepo.getAllBanners();
      final banners = response.results;
      emit(state.copyWith(
        status: BannerStatus.success,
        banners: banners,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: BannerStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }
}
