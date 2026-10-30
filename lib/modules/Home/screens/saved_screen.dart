import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/widget/recent_places_tab.dart';
import 'package:thewasher/modules/Home/widget/saved_places_tab.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/tab_bar/tab_bar_shared.dart';
import 'package:thewasher/utilties/navigator.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:google_api_headers/google_api_headers.dart';
import 'package:thewasher/api/app_config.dart';

class SavedScreen extends StatefulWidget {
  Completer<GoogleMapController> myController;
  SavedScreen({Key? key, required this.myController}) : super(key: key);

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController nameController = TextEditingController();
  late int currentTabIndex;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    currentTabIndex = 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.lightStatusBarIconsWithTransparentColorStyle,
      child: Scaffold(
        backgroundColor: ColorManager.white,
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: 110.h,
                    decoration: BoxDecoration(
                        color: ColorManager.primary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.r),
                          bottomRight: Radius.circular(12.r),
                        )),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15.w, 25.h, 15.w, 0.h),
                      child: InkWell(
                        onTap: () {
                          pop(context);
                        },
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.arrow_back_ios_sharp,
                              color: ColorManager.white,
                            ),
                            6.pw,
                            Text(
                              translate(AppStrings.savedPlaces),
                              style: AppStyles.titleWhite16Bold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 812.h - 110.h,
                    color: ColorManager.white,
                    child: Column(
                      children: <Widget>[
                        50.ph,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: TabBarSharedWidget(
                              tabController: _tabController,
                              currentTabIndex: currentTabIndex,
                              tabWidget: <Widget>[
                                Tab(
                                  text: translate(AppStrings.savedPlaces),
                                ),
                                Tab(
                                  text: translate(AppStrings.recentPlaces),
                                ),
                              ],
                              onTab: (int index) {
                                setState(() {
                                  currentTabIndex = index;
                                });
                              }),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              SavedPlacesTab(myController: widget.myController),
                              RecentPlacesTab(
                                  myController: widget.myController,
                                  nameController: nameController)
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Positioned(
                top: 90.h,
                left: 16.w,
                right: 16.w,
                child: InkWell(
                  onTap: () {
                    // _handlePressButton(context);
                  },
                  child: Container(
                    width: 343.w,
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: ColorManager.black2.withOpacity(0.18),
                            offset: const Offset(0, 3),
                            blurRadius: 6.r),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.p10, vertical: AppPadding.p14),
                    child: Text(
                      "Add new place...",
                      style: AppStyles.titleGray16Regular,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _handlePressButton(context) async {
  //   Prediction? p = await PlacesAutocomplete.show(
  //     context: context,
  //     apiKey: Platform.isAndroid ? AppConfig.kApiKey : AppConfig.kApiKeyIos,
  //     mode: Mode.overlay,
  //     language: Localizations.localeOf(context).languageCode,
  //     types: [""],
  //     onError: (value) {
  //       print(value.predictions);
  //       print(value.status);
  //       print(value.errorMessage);
  //     },
  //     strictbounds: false,
  //     decoration: InputDecoration(
  //       hintText: 'Search',
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(20.r),
  //         borderSide: const BorderSide(
  //           color: ColorManager.white,
  //         ),
  //       ),
  //     ),
  //     components: [Component(Component.country, "eg")],
  //   );
  //   displayPrediction(p!);
  // }

  // Future<void> displayPrediction(Prediction p) async {
  //   GoogleMapsPlaces places = GoogleMapsPlaces(
  //       apiKey: Platform.isAndroid ? AppConfig.kApiKey : AppConfig.kApiKeyIos,
  //       apiHeaders: await const GoogleApiHeaders().getHeaders());

  //   PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

  //   final lat = detail.result.geometry!.location.lat;
  //   final lng = detail.result.geometry!.location.lng;
  //   AlertHelper.savedAlert(context, nameController, false, detail: detail);
  //   setState(() {});
  // }

}
