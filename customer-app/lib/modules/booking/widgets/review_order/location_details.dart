import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/booking/widgets/location/fixed_map.dart';

class LocationDetails extends StatelessWidget {
  final Location location;
  const LocationDetails({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppPadding.p18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            translate(AppStrings.address),
            style: AppStyles.title16Bold.copyWith(color: ColorManager.black),
          ),
          AppPadding.p8.ph,
          Row(
            children: [
              if (location.savedName != null)
                Text(
                  location.savedName!,
                  style: AppStyles.subtextGray14Regular,
                ),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  ' (${location.streetName})',
                  style: AppStyles.subtextGray14Regular.copyWith(
                    color: ColorManager.black,
                  ),
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
          AppPadding.p8.ph,
          FixedMap(
            height: 85,
            latLng: LatLng(location.latitude!, location.longitude!),
          ),
        ],
      ),
    );
  }
}
