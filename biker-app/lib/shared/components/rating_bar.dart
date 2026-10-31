import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';

class RatingBarShared extends StatefulWidget {
  final double ratingCount;
  final double? itemSize;
  final Function(double)? onRatingUpdate;
  const RatingBarShared({
    super.key,
    required this.ratingCount,
    this.itemSize = 18,
    this.onRatingUpdate,
  });

  @override
  State<RatingBarShared> createState() => _RatingBarSharedState();
}

class _RatingBarSharedState extends State<RatingBarShared> {
  late double ratingCount;

  @override
  void initState() {
    super.initState();
    ratingCount = widget.ratingCount;
  }

  @override
  Widget build(BuildContext context) {
    return RatingBar(
        initialRating: ratingCount,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemSize: widget.itemSize!.r,
        glow: false,
        ratingWidget: RatingWidget(
          full: SvgPicture.asset(
            ImageAssets.starSelected,
          ),
          half: SvgPicture.asset(
            ImageAssets.starUnselected,
          ),
          empty: SvgPicture.asset(
            ImageAssets.starUnselected,
          ),
        ),
        itemPadding: EdgeInsets.symmetric(horizontal: 4.w),
        onRatingUpdate: widget.onRatingUpdate ?? (rate) {});
  }
}
