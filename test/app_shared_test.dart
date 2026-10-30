import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewhsherbiker/api/shared.dart';

void main() {
  // Regression: the getters used to assign the static field but return null,
  // so the interceptor never saw the refresh token and every token expiry
  // logged the biker out.
  test('getters return the stored values', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppShared.sharedPreferencesRefreshTokenKey: 'refresh-123',
      AppShared.sharedPreferenceTokenKey: 'access-456',
      AppShared.sharedPreferencesPhone: '+966500000000',
    });

    expect(await AppShared.getRefreshToken(), 'refresh-123');
    expect(await AppShared.getPhone(), '+966500000000');
    await AppShared.getToken();
    expect(AppShared.token, 'access-456');
  });

  test('malformed tokens count as expired instead of throwing', () {
    expect(AppShared.isTokenExpired(''), isTrue);
    expect(AppShared.isTokenExpired('not-a-jwt'), isTrue);
  });
}
