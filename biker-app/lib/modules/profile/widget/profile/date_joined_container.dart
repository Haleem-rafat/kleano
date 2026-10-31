import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_list_row.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';

class DateJoinedContainer extends StatelessWidget {
  final String timeCreateAt;
  const DateJoinedContainer({super.key, required this.timeCreateAt});

  String _formatDate(String dateString) {
    try {
      // Parse the date string (format: dd/M/yyyy)
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final date = DateTime(year, month, day);

        // Format as "dd MMM yyyy" (e.g., "11 Sep 2025")
        return DateFormat('dd MMM yyyy', 'en').format(date);
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  String _calculateDuration(BuildContext context, String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final joinDate = DateTime(year, month, day);
        final now = DateTime.now();
        final difference = now.difference(joinDate);
        final days = difference.inDays;

        if (days < 30) {
          return '$days ${days == 1 ? translate(AppStrings.day) : translate(AppStrings.days)}';
        } else if (days < 365) {
          final months = (days / 30).floor();
          return '$months ${months == 1 ? translate(AppStrings.month) : translate(AppStrings.months)}';
        } else {
          final years = (days / 365).floor();
          final remainingMonths = ((days % 365) / 30).floor();
          if (remainingMonths > 0) {
            return '$years ${years == 1 ? translate(AppStrings.year) : translate(AppStrings.years)} $remainingMonths ${remainingMonths == 1 ? translate(AppStrings.month) : translate(AppStrings.months)}';
          }
          return '$years ${years == 1 ? translate(AppStrings.year) : translate(AppStrings.years)}';
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String date = _formatDate(timeCreateAt);
    final String duration = _calculateDuration(context, timeCreateAt);
    return KCard(
      padding: EdgeInsets.zero,
      child: KListRow(
        leading: SvgPicture.asset(
          ImageAssets.joinedLogo,
          width: KSpace.xxl,
          height: KSpace.xxl,
        ),
        title: tr(context, AppStrings.dateJoined),
        subtitle: duration.isEmpty
            ? date
            : '$date\n${tr(context, AppStrings.memberSince)} $duration',
      ),
    );
  }
}
