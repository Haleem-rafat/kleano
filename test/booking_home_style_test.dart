import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/modules/booking/home_style.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('most booked is the most frequent service, ties to the latest', () {
    expect(mostFrequentId(<String?>[]), isNull);
    expect(mostFrequentId(<String?>['a', 'b', 'b', null]), 'b');
    expect(mostFrequentId(<String?>['a', 'b']), 'a');
  });

  test('the chosen Home style is remembered', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await HomeStyleSetting.set(HomeStyle.offersFirst);
    HomeStyleSetting.style.value = HomeStyle.current;
    await HomeStyleSetting.load();
    expect(HomeStyleSetting.style.value, HomeStyle.offersFirst);
  });

  test('an unknown saved style falls back to the Mix Home', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'kleano_home_style': 'gone',
    });
    await HomeStyleSetting.load();
    expect(HomeStyleSetting.style.value, HomeStyle.mix);
  });
}
