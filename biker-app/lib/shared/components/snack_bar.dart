import 'package:flutter/material.dart';

void showSnackBar(
    {required BuildContext buildContext, required String message}) {
  ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
    elevation: 20,
    content: Text(
      message,
      maxLines: 7,
    ),
  ));
}
