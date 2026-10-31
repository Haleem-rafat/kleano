import 'package:flutter_test/flutter_test.dart';
import 'package:thewasher/core/enums/status.dart';
import 'package:thewasher/modules/Auth/cubit/auth_cubit.dart';
import 'package:thewasher/modules/Auth/cubit/auth_state.dart';
import 'package:thewasher/modules/Auth/model/auth_model.dart';
import 'package:thewasher/modules/Auth/repository/auth_repository.dart';

/// AuthCubit is app-wide (lib/app.dart), so statuses from an earlier flow
/// survive into the next one. The OTP screen navigates home on
/// `loginStatus == loaded || verifyOTPStatus == loaded`, so a stale `loaded`
/// sends the user home on the next emission without a valid login.
class FakeAuthRepository extends AuthRepository {
  @override
  Future<void> sendOTP({required String phone}) async {}

  @override
  Future<AuthModel> login(
          {required String phone,
          required String fcmToken,
          required String otp}) async =>
      throw Exception('Invalid OTP');

  @override
  Future<AuthModel> verifySignupOTP(
          {required String otp, required String phone}) async =>
      _model;
}

final AuthModel _model = AuthModel.fromJson(<String, dynamic>{
  'location': <String, dynamic>{
    'latitude': 0,
    'longitude': 0,
    'streetName': '',
    'subAdministrativeArea': '',
    'country': ''
  },
  '_id': 'id',
  'userName': 'Test',
  'phone': '+201202939672',
  'isSuspended': false,
  'isDeleted': false,
  'points': 0,
  'walletBalance': 0,
  'language': 'en',
  'isAllowNotification': true,
  'rating': 0,
  'createdAt': '',
  'updatedAt': '',
  '__v': 10,
  'access_token': 'a',
  'refresh_token': 'r',
});

bool goesHome(AuthState s) =>
    s.loginStatus == RequestStatus.loaded ||
    s.verifyOTPStatus == RequestStatus.loaded;

void main() {
  test('a failed login after an earlier sign-up never looks like success',
      () async {
    final AuthCubit cubit = AuthCubit(repository: FakeAuthRepository());
    await cubit.verifySignupOTP(otp: '000000', phone: '+201202939672');
    expect(cubit.state.verifyOTPStatus, RequestStatus.loaded);

    final List<AuthState> seen = <AuthState>[];
    final sub = cubit.stream.listen(seen.add);
    await cubit.sendOTP(phone: '+201202939672');
    await cubit.login(phone: '+201202939672', fcmToken: 't', otp: '123456');
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(seen.where(goesHome), isEmpty);
    expect(cubit.state.loginStatus, RequestStatus.failure);
    expect(cubit.state.loginErrorMessage, 'Invalid OTP');
  });

  test('the JSON the backend returns for +201202939672 parses', () {
    expect(_model.phone, '+201202939672');
  });
}
