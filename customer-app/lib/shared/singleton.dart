import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class GeneralSingleton {
  static final GeneralSingleton _singleton = GeneralSingleton._internal();
  factory GeneralSingleton() {
    return _singleton;
  }

  GeneralSingleton._internal();
  // Create a shared varible

  String? fcmToken;
  String? userName;
  String? gender;
  XFile? userImage;
  String? characterUserName;
  LatLng? currentPositionGuest;
  String? country;
  DateTime? orderTime;
  String? nearByDescription;
  bool completedOrder = false;
  bool openTracking = false;
  bool isCarFreshened = false;

  List<Widget>? textForms;
  int? step = -1;
  String timeOnTheWay = '';
  String timeArrived = '';
  String timeWashing = '';
  String timeComplete = '';
  String? orderId;
  num? totalPay;
  int? orderIndex;
  num appliedPoints = 0;
  bool notificationOpen = false;
  bool hasUnreadNotification = false;

  void resetTimes() {
    timeOnTheWay = '';
    timeArrived = '';
    timeWashing = '';
    timeComplete = '';
  }

  void resetAll() {
    fcmToken = null;
    userName = null;
    gender = null;
    userImage = null;
    characterUserName = null;
    currentPositionGuest = null;
    country = null;
    orderTime = null;
    nearByDescription = null;
    completedOrder = false;
    openTracking = false;
    isCarFreshened = false;
    textForms = null;
    step = -1;
    timeOnTheWay = '';
    timeArrived = '';
    timeWashing = '';
    timeComplete = '';
    orderId = null;
    totalPay = 0;
    orderIndex = null;
    appliedPoints = 0;
    notificationOpen = false;
    hasUnreadNotification = false;
  }
}
