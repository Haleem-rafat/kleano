import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:thewhsherbiker/api/api_service.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/models/error_model.dart';
import 'package:thewhsherbiker/modules/Auth/data/model/auth_model.dart';
import 'package:thewhsherbiker/modules/notification/helpers/notification_helper.dart';
import 'package:thewhsherbiker/modules/notification/widget/firebase_notification.dart';
import 'package:thewhsherbiker/responses/generic_response.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/Auth/data/repo/auth_repo.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  String token = '';
  bool logout = false;
  LatLng currentPosition = const LatLng(0, 0);
  String currentAddress = "";
  String administrativeArea = "";
  String country = "";
  final FirebaseCloudMessagingService firebaseCloudMessagingService =
      FirebaseCloudMessagingService();
  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {}
    }
    if (permission == LocationPermission.deniedForever) {}
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = LatLng(position.latitude, position.longitude);
    List<Placemark> placeMarks = await placemarkFromCoordinates(
        currentPosition.latitude, currentPosition.longitude);
    currentAddress = placeMarks.first.street!;
    administrativeArea = placeMarks.first.subAdministrativeArea!;
    country = placeMarks.first.country!;
  }

  AuthBloc() : super(AuthInitial()) {
    on<BikerLogin>((BikerLogin event, Emitter<AuthState> emit) async {
      try {
        print("🔐 Biker Login initiated...");
        emit(BikerLoginLoading());

        // Get FCM token for push notifications
        String? fcmToken = NotificationHelper.getFCMToken();
        print("📱 Attempting to get FCM token from NotificationHelper...");

        // If token is not available yet, try to get it directly
        if (fcmToken == null || fcmToken.isEmpty) {
          print("⚠️ Token not available from helper, trying direct fetch...");
          fcmToken = await firebaseCloudMessagingService.getFcmToken();
        }

        // Use the token or fallback to a placeholder
        final String tokenToSend = fcmToken ?? "FCM_TOKEN_UNAVAILABLE";

        if (fcmToken != null && fcmToken.isNotEmpty) {
          print("✅ FCM Token retrieved successfully!");
          print(
              "📤 Sending FCM token to backend: ${fcmToken.substring(0, 30)}...");
        } else {
          print("❌ FCM Token unavailable - sending placeholder");
        }

        final Either<ErrorModel, GenericResponse> response =
            await AuthRepo.bikerLogin(
                event.userName, event.passWord, tokenToSend);
        response.fold(
          (ErrorModel l) {
            print(
                "❌ Login failed: ${l.getErrorMessage(Localizations.localeOf(event.context).languageCode)}");
            emit(BikerLoginFailed(
              error: l.getErrorMessage(
                  Localizations.localeOf(event.context).languageCode),
            ));
          },
          (GenericResponse r) async {
            print("✅ Login successful!");
            AppShared.setToken(r.result!.accessToken!);
            AppShared.setRefreshToken(r.result!.refreshToken!);
            sl<ProfileBloc>().add(BikerProfile());
            emit(BikerLoginSuccess(authModel: r.result!));
          },
        );
      } catch (e) {
        print("❌ Login error: $e");
        emit(BikerLoginFailed(error: e.toString()));
      }
    });

    on<BikerCheckPhone>((BikerCheckPhone event, Emitter<AuthState> emit) async {
      try {
        print("Biker Check Phone ... ");
        emit(BikerCheckPhoneLoading());
        final String response = await AuthRepo.bikerCheckPhone(
          event.phoneNumber,
        );
        if (response.isNotEmpty) {
          token = response;
          emit(BikerCheckPhoneSuccess(token: response));
        } else {
          emit(BikerCheckPhoneFailed(
              error: translate(AppStrings.phoneNotAlreadyExist)));
        }
        ;
      } catch (e) {
        emit(BikerLoginFailed(error: e.toString()));
      }
    });

    on<BikerResetPassword>(
        (BikerResetPassword event, Emitter<AuthState> emit) async {
      try {
        print("Biker Reset Password ... ");
        emit(BikerResetPasswordLoading());
        final bool response =
            await AuthRepo.bikerResetPassword(event.newPassword, event.token);

        if (response) {
          emit(BikerResetPasswordSuccess());
        } else {
          emit(BikerResetPasswordFailed(error: "Error"));
        }
        ;
      } catch (e) {
        emit(BikerResetPasswordFailed(error: e.toString()));
      }
    });

    on<BikerUpdatePassword>(
        (BikerUpdatePassword event, Emitter<AuthState> emit) async {
      try {
        print("Biker Update Password ... ");
        emit(BikerUpdatePasswordLoading());
        final Either<ErrorModel, bool> response =
            await AuthRepo.bikerUpdatePassword(
          event.oldPassword,
          event.newPassword,
        );

        response.fold(
          (ErrorModel l) => emit(
            BikerUpdatePasswordFailed(
              error: l.getErrorMessage(
                  Localizations.localeOf(event.context).languageCode),
            ),
          ),
          (bool r) => emit(BikerUpdatePasswordSuccess()),
        );
      } catch (e) {
        emit(BikerUpdatePasswordFailed(error: e.toString()));
      }
    });

    on<BikerLogOut>((BikerLogOut event, Emitter<AuthState> emit) async {
      try {
        print("Biker LogOut ... ");
        emit(BikerLogOutLoading());
        logout = true;

        // Get FCM token for logout
        String? fcmToken = NotificationHelper.getFCMToken();

        // If token is not available, try to get it directly
        if (fcmToken == null || fcmToken.isEmpty) {
          fcmToken = await firebaseCloudMessagingService.getFcmToken();
        }

        // Use the token or fallback to a placeholder
        final String tokenToSend = fcmToken ?? "FCM_TOKEN_UNAVAILABLE";
        print("FCM Token for logout: $tokenToSend");

        final bool response = await AuthRepo.bikerLogOut(tokenToSend);
        if (response) {
          logout = false;
          AppShared.setToken("");
          AppShared.setRefreshToken("");

          // Clean up notifications on logout
          await NotificationHelper.cancelAllNotifications();

          emit(BikerLogOutSuccess());
          emit(AuthInitial());
        } else {
          emit(BikerLogOutFailed(error: "Error"));
        }
        ;
      } catch (e) {
        emit(BikerLogOutFailed(error: e.toString()));
      }
    });

    on<BikerSplash>((BikerSplash event, Emitter<AuthState> emit) async {
      try {
        print("Biker Splash ... ");
        emit(BikerSplashLoading());
        await AppShared.getToken();
        if (AppShared.token.isNotEmpty) {
          // Add timeout to prevent hanging
          final String? response = await ApiService.refreshToken().timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              print("Token refresh timeout");
              return null;
            },
          );
          if (response != null) {
            AppShared.setRefreshToken(response);
            emit(BikerSplashAlreadyUser());
          } else {
            AppShared.setToken("");
            emit(BikerSplashExpiredToken());
          }
        } else {
          emit(BikerSplashNotUser());
        }
      } catch (e) {
        print("Biker Splash error: $e");
        emit(BikerSplashNotUser());
      }
    });
  }
}
