import 'package:flutter_test/flutter_test.dart';
import 'package:thewhsherbiker/utilties/whatsapp_number.dart';

void main() {
  test('keeps the country code a stored number already has', () {
    expect(whatsAppNumber('+201202939672'), '201202939672');
    expect(whatsAppNumber('+966 533 720 654'), '966533720654');
    expect(whatsAppNumber('00201202939672'), '201202939672');
    expect(whatsAppNumber('201202939672'), '201202939672');
  });

  test('a bare local number defaults to Egypt', () {
    expect(whatsAppNumber('01202939672'), '201202939672');
    expect(whatsAppNumber('1202939672'), '201202939672');
  });
}
