import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

Future<void> launchMap({required String lat, required String long}) async {
  final String url =
      'https://www.google.com/maps/search/?api=1&query=$lat,$long';
  try {
    await launchUrl(Uri.parse(url));
  } catch (e) {
    log("Could not launch $e");
  }
}
