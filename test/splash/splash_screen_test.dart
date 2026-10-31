import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thewhsherbiker/modules/splash/splash_screen.dart';

void main() {
  test('the profile can never hold the splash for long', () {
    expect(
      SplashScreen.profileWait,
      lessThanOrEqualTo(const Duration(seconds: 10)),
    );
    expect(const SplashScreen(), isA<Widget>());
  });
}
