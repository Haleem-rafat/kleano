import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';

class ColorType {
  String colorName;
  int? id;
  Color? color;

  ColorType({required this.colorName, this.id, this.color});
}

List<ColorType> colorList = [
  ColorType(colorName: "White", id: 0, color: ColorManager.white),
  ColorType(colorName: "Gray", id: 1, color: ColorManager.divider),
  ColorType(colorName: "Red", id: 2, color: ColorManager.red),
  ColorType(colorName: "Black", id: 3, color: ColorManager.black2),
  ColorType(colorName: "Blue", id: 4, color: ColorManager.blue),
  ColorType(colorName: "Green", id: 5, color: ColorManager.green),
  ColorType(colorName: "Orange", id: 6, color: ColorManager.orange),
  ColorType(colorName: "Yellow", id: 7, color: ColorManager.yellow),
];
