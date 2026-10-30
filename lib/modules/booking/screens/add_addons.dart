import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/booking/widgets/add_ons/card_addons.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class AddAddOns extends StatelessWidget {
  const AddAddOns({super.key});

  @override
  Widget build(BuildContext context) {
    int indexAddOns = 0;
    OffersBloc offersBloc = sl<OffersBloc>();
    void addOrRemoveAddOns() {
      if (sl<OffersBloc>()
          .cartAddOnsList
          .contains(offersBloc.addOnsList[indexAddOns])) {
        var deleteCartService = sl<OffersBloc>()
            .cartAddOnsList
            .indexOf(offersBloc.addOnsList[indexAddOns]);
        offersBloc.add(DeleteExtraCart(
            index: deleteCartService,
            extra: offersBloc.addOnsList[indexAddOns]));
      } else {
        offersBloc.add(AddExtraCart(extra: offersBloc.addOnsList[indexAddOns]));
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
      child: StatefulBuilder(builder: (context, myState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate(AppStrings.addOns),
              style: AppStyles.title16Bold.copyWith(
                color: ColorManager.black,
              ),
            ),
            SizedBox(
              height: AppPadding.p16.h,
            ),
            offersBloc.addOnsList.isEmpty
                ? Center(child: Text(translate(AppStrings.noAddonsRequested)))
                : Expanded(
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 12.h,
                      scrollDirection: Axis.vertical,
                      childAspectRatio: (120.w / 190.h),
                      children:
                          offersBloc.addOnsList.asMap().keys.map((int index) {
                        return GestureDetector(
                            onTap: () {
                              myState(() {
                                indexAddOns = index;
                                addOrRemoveAddOns();
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: CardAddOns(
                              index: index,
                              onTap: () {
                                myState(() {
                                  indexAddOns = index;
                                  addOrRemoveAddOns();
                                });
                              },
                            ));
                      }).toList(),
                    ),
                  ),
          ],
        );
      }),
    );
  }
}
