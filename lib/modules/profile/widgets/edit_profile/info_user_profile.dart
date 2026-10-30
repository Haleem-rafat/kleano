import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';

class PersonalInformation extends StatelessWidget {
  final Profile user;
  const PersonalInformation({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final List<_InfoItem> items = [
      _InfoItem(
        icon: Icons.person_outline,
        title: translate(AppStrings.name),
        value: user.userName ?? '---',
      ),
      _InfoItem(
        icon: Icons.email_outlined,
        title: translate(AppStrings.email),
        value: user.email ?? '---',
      ),
      _InfoItem(
        icon: Icons.wc_outlined,
        title: translate(AppStrings.gender),
        value: user.gender ?? '---',
      ),
      // Date of Birth

      _InfoItem(
        icon: Icons.cake_outlined,
        title: translate(AppStrings.dateOfBirth),
        value: user.dob ?? '---',
      ),
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorManager.gray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, size: 20.sp, color: ColorManager.primary),
                  12.w.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppStyles.titleGray16Regular.copyWith(
                            color: ColorManager.darkGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        6.h.verticalSpace,
                        Text(
                          item.value,
                          style: AppStyles.titleGray16Regular.copyWith(
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (index != items.length - 1) ...[
                14.h.verticalSpace,
                Divider(
                  color: ColorManager.lightGray,
                  thickness: 1,
                ),
                14.h.verticalSpace,
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String title;
  final String value;

  _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });
}
