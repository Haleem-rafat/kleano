import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/shared/components/shimmering/main_shimmering_widget.dart';

class CircleImageShared extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final String name;
  const CircleImageShared({
    super.key,
    required this.imageUrl,
    required this.radius,
    required this.name,
  });
  @override
  Widget build(BuildContext context) {
    String characterUserName;

    characterUserName = name.split('').first;

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (BuildContext context, _) {
            return ShimmeringWidget(
              child: CircleAvatar(
                radius: radius,
                backgroundColor: ColorManager.primary.withValues(alpha: 0.1),
              ),
            );
          },
          imageBuilder: (BuildContext context, _) {
            return CircleAvatar(
              radius: radius,
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: ColorManager.primary.withValues(alpha: 0.1),
            );
          },
          errorWidget: (BuildContext context, _, Object dynamic) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: ColorManager.primaryLight,
              child: Text(
                characterUserName,
                style: AppStyles.title16Bold.copyWith(
                  color: ColorManager.secondary,
                  fontSize: 12.sp,
                ),
              ),
            );
          }),
    );
  }
}
