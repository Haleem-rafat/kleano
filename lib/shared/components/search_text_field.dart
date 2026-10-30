import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class DropdownSearchShared extends StatelessWidget {
  final Function(dynamic) onChanged;
  final String hintText;
  final List<dynamic> items;
  final dynamic initItem;
  final dynamic selectedItem;
  final String? Function(dynamic)? validator;
  final bool? itemBuilder;
  const DropdownSearchShared(
      {super.key,
      required this.onChanged,
      required this.hintText,
      required this.items,
      this.initItem,
      this.validator,
      this.selectedItem,
      this.itemBuilder = false});

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<dynamic>.search(
      hintText: hintText,
      items: items,
      validator: validator,
      initialItem: initItem,
      excludeSelected: false,
      decoration: CustomDropdownDecoration(
        listItemStyle:
            AppStyles.subtext14Regular.copyWith(color: ColorManager.darkGrey),
        hintStyle:
            AppStyles.subtext14Regular.copyWith(color: ColorManager.medGray),
        errorStyle: AppStyles.subtext14Regular.copyWith(color: Colors.red),
        closedBorder: Border.all(color: Colors.transparent),
        expandedBorder: Border.all(color: Colors.transparent),
      ),
      listItemBuilder: (context, item, isSelected, onItemSelect) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorManager.primary.withOpacity(0.1)
                : Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.toString(),
                  style: AppStyles.subtext14Regular.copyWith(
                    color: isSelected
                        ? ColorManager.primary
                        : ColorManager.darkGrey,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 20.sp,
                  color: ColorManager.primary,
                ),
            ],
          ),
        );
      },
      onChanged: onChanged,
    );
  }
}
