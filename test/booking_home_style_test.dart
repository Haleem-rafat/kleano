import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/modules/booking/home_style.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the chosen Home style is remembered', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await HomeStyleSetting.set(HomeStyle.offersFirst);
    HomeStyleSetting.style.value = HomeStyle.current;
    await HomeStyleSetting.load();
    expect(HomeStyleSetting.style.value, HomeStyle.offersFirst);
  });

  test('an unknown saved style falls back to the current Home', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'kleano_home_style': 'gone',
    });
    await HomeStyleSetting.load();
    expect(HomeStyleSetting.style.value, HomeStyle.current);
  });
}
