import 'package:flutter_test/flutter_test.dart';
import 'package:thewasher/modules/booking/home_style.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('most booked is the most frequent service, ties to the latest', () {
    expect(mostFrequentId(<String?>[]), isNull);
    expect(mostFrequentId(<String?>['a', 'b', 'b', null]), 'b');
    expect(mostFrequentId(<String?>['a', 'b']), 'a');
  });
}
