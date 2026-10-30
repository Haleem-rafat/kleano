import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/values_manager.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({
    super.key,
  });

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, 60.h),
        child: AppBarShared(
          titleAppBar: "Add New Address",
          isTextOnly: false,
        ),
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
