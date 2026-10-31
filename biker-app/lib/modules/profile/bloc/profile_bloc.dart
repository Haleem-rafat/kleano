import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:thewhsherbiker/core/utilis/enums.dart';
import 'package:thewhsherbiker/models/error_model.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/biker_schedule_model.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';
import 'package:thewhsherbiker/modules/profile/data/model/total_commission_model.dart';
import 'package:thewhsherbiker/modules/profile/data/repo/profile_repo.dart';
import 'package:thewhsherbiker/responses/base_response.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileModel profile = ProfileModel();
  String characterUserName = '';

  ProfileBloc() : super(ProfileInitial()) {
    // Fetch Profile
    on<BikerProfile>(_onBikerProfile);

    // Edit Profile
    on<BikerProfileEdit>(_onBikerProfileEdit);

    // Update Status
    on<BikerUpdateStatus>(_onBikerUpdateStatus);

    // Update Language
    on<UpdateBikerLanguage>(_onUpdateBikerLanguage);

    // Get Total Washes
    on<BikerGetTotalWashes>(_onBikerGetTotalWashes);

    // Get Total Commission
    on<BikerGetTotalCommission>(_onBikerGetTotalCommission);

    // Get Schedule
    on<BikerGetSchedule>(_onBikerGetSchedule);
  }

  // Handle Biker Profile Fetch
  Future<void> _onBikerProfile(
      BikerProfile event, Emitter<ProfileState> emit) async {
    try {
      emit(BikerProfileLoading());
      final response = await ProfileRepo.bikerProfile();

      if (response.success) {
        profile = response.result!;
        characterUserName = _generateCharacterUserName(profile.userName);
        emit(BikerProfileSuccess(profile: profile));
      } else {
        emit(BikerProfileFailed(error: response.error!.first.message));
      }
    } catch (e) {
      emit(BikerProfileFailed(error: e.toString()));
    }
  }

  // Handle Profile Edit
  Future<void> _onBikerProfileEdit(
      BikerProfileEdit event, Emitter<ProfileState> emit) async {
    try {
      emit(BikerProfileEditLoading());
      final bool success =
          await ProfileRepo.bikerProfileEdit(event.name, event.image);

      if (success) {
        _updateProfile(event.name, event.image);
        add(BikerProfile());
        emit(BikerProfileEditSuccess());
      } else {
        emit(BikerProfileEditFailed(error: "Error updating profile"));
      }
    } catch (e) {
      emit(BikerProfileEditFailed(error: e.toString()));
    }
  }

  // Handle Biker Status Update
  Future<void> _onBikerUpdateStatus(
      BikerUpdateStatus event, Emitter<ProfileState> emit) async {
    try {
      final bool success = await ProfileRepo.bikerUpdateStatus(event.status);
      if (success) {
        profile.status = event.status.toString();
        _manageSocketConnection(profile.status!);
        emit(BikerProfileSuccess(profile: profile));
      } else {
        emit(BikerUpdateStatusFailed());
      }
    } catch (e) {
      debugPrint(e.toString());
      emit(BikerUpdateStatusFailed());
    }
  }

  // Handle Language Update
  Future<void> _onUpdateBikerLanguage(
      UpdateBikerLanguage event, Emitter<ProfileState> emit) async {
    try {
      emit(ChangeBikerLanguageLoading());
      final BaseResponse response =
          await ProfileRepo.updateBikerLanguage(language: event.languageCode);

      if (response.success) {
        emit(ChangeBikerLanguageSuccess());
      } else {
        emit(ChangeBikerLanguageFailed(
            errorModel: response.errorModel, error: response.errorMessage));
      }
    } catch (e) {
      emit(ChangeBikerLanguageFailed(error: e.toString()));
    }
  }

  String _generateCharacterUserName(String? userName) {
    if (userName == null) return '';
    final List<String> nameParts = userName.split(' ');
    return nameParts.length > 1
        ? '${nameParts.first[0].toUpperCase()}${nameParts.last[0].toUpperCase()}'
        : userName[0].toUpperCase();
  }

  void _updateProfile(String name, String image) {
    profile.userName = name;
    if (image.isNotEmpty) {
      profile.imageLink = image;
    }
  }

  void _manageSocketConnection(String status) {
    final homeBloc = sl<HomeBloc>();

    if (status == BikerStatus.ONLINE.name) {
      debugPrint('🟢 Biker status changed to ONLINE - initiating socket connection');
      // Connect socket when biker goes online
      homeBloc.socketService.connect(
        onNewOrder: (order) {
          debugPrint("📦 New order received in ProfileBloc context");
          homeBloc.add(BikerGetOrdersAccept());
        },
        onError: (error) {
          debugPrint("❌ Socket error in ProfileBloc context: $error");
        },
      );
    } else {
      debugPrint('🔴 Biker status changed to OFFLINE - disconnecting socket');
      // Disconnect socket when biker goes offline
      homeBloc.socketService.disconnect();
    }
  }

  Future<void> _onBikerGetTotalWashes(
      BikerGetTotalWashes event, Emitter<ProfileState> emit) async {
    try {
      emit(BikerGetTotalWashesLoading());
      final int totalWashes =
          await ProfileRepo.getTotalWashes(status: event.status);

      profile.totalWashes = totalWashes;
      emit(BikerProfileSuccess(profile: profile));
    } catch (e) {
      emit(BikerGetTotalWashesFailed(error: e.toString()));
    }
  }

  Future<void> _onBikerGetTotalCommission(
      BikerGetTotalCommission event, Emitter<ProfileState> emit) async {
    try {
      emit(BikerGetTotalCommissionLoading());
      final TotalCommissionModel? totalCommission =
          await ProfileRepo.getTotalCommission();

      if (totalCommission != null) {
        profile.totalCommission = totalCommission;
        emit(BikerGetTotalCommissionSuccess(totalCommission: totalCommission));
        emit(BikerProfileSuccess(profile: profile));
      } else {
        emit(BikerGetTotalCommissionFailed(
            error: "Failed to fetch total commission"));
      }
    } catch (e) {
      emit(BikerGetTotalCommissionFailed(error: e.toString()));
    }
  }

  String? getUserImage() =>
      profile.imageLink?.contains('/data') == false ? profile.imageLink : null;

  File? getLocalImageFile() => profile.imageLink?.contains('/data') == true
      ? File(profile.imageLink!)
      : null;

  String getUserName() => profile.userName ?? characterUserName;

  Future<void> _onBikerGetSchedule(
      BikerGetSchedule event, Emitter<ProfileState> emit) async {
    try {
      emit(BikerGetScheduleLoading());
      final BikerScheduleModel? schedule = await ProfileRepo.getBikerSchedule();

      if (schedule != null) {
        emit(BikerGetScheduleSuccess(schedule: schedule));
      } else {
        emit(BikerGetScheduleFailed(error: "Failed to fetch schedule"));
      }
    } catch (e) {
      emit(BikerGetScheduleFailed(error: e.toString()));
    }
  }
}
