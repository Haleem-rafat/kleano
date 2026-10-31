import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/modules/booking/bottom_sheet/connecting_nearest_biker.dart';

Future<void> waitingBiker({required BuildContext context}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20.r),
        topLeft: Radius.circular(20.r),
      ),
    ),
    isScrollControlled: true,
    builder: (BuildContext context) {
      return const WaitForBikerBottomSheet();
    },
  );
}
