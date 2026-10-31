import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';

export 'package:geocoding/geocoding.dart' show Placemark;

final Geocoding _geocoding = Geocoding();
final Geocoding _geocodingEn = Geocoding(locale: const Locale('en', 'US'));
final RegExp _nonLatin = RegExp(r'[^\u0000-ɏ\s]');

/// Reverse-geocodes [latitude]/[longitude] in the device language.
///
/// The backend only recognises English country names ("Saudi Arabia"), so when
/// the device returns a localised country (e.g. "السعودية") the country is
/// resolved again in English while street/area names stay localised.
Future<List<Placemark>> placemarkFromCoordinates(
    double latitude, double longitude) async {
  final List<Placemark> placemarks =
      await _geocoding.placemarkFromCoordinates(latitude, longitude);
  if (placemarks.isEmpty) return placemarks;

  final Placemark first = placemarks.first;
  if (!_nonLatin.hasMatch(first.country ?? '')) return placemarks;

  final List<Placemark> english =
      await _geocodingEn.placemarkFromCoordinates(latitude, longitude);
  if (english.isEmpty) return placemarks;

  return <Placemark>[
    Placemark(
      name: first.name,
      street: first.street,
      isoCountryCode: first.isoCountryCode,
      country: english.first.country,
      postalCode: first.postalCode,
      administrativeArea: first.administrativeArea,
      subAdministrativeArea: first.subAdministrativeArea,
      locality: first.locality,
      subLocality: first.subLocality,
      thoroughfare: first.thoroughfare,
      subThoroughfare: first.subThoroughfare,
    ),
    ...placemarks.skip(1),
  ];
}
