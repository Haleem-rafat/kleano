import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/components/text-form-shared.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class ApplyPromCode extends StatefulWidget {
  final String orderId;
  const ApplyPromCode({super.key, required this.orderId});

  @override
  State<ApplyPromCode> createState() => _ApplyPromCodeState();
}

class _ApplyPromCodeState extends State<ApplyPromCode> {
  @override
  Widget build(BuildContext context) {
    bool showPromoCode = sl.call<PromoBloc>.call().code != '' ? true : false;
    return Padding(
      padding: EdgeInsets.only(top: AppPadding.p25.h),
      child: StatefulBuilder(
        builder: (context, myState) {
          return SizedBox(
            width: 318.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SvgPicture.asset(
                      AssetsManager.bookMarkAdd,
                      height: AppSize.s24.h,
                      width: AppSize.s24.w,
                    ),
                    AppPadding.p16.pw,

                    Text(
                      translate(AppStrings.promoCode),
                      style: AppStyles.title16Bold.copyWith(
                        color: ColorManager.black,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        myState(() {
                          showPromoCode = !showPromoCode;
                        });
                      },
                      child: Text(
                        translate(
                          showPromoCode ? AppStrings.hide : AppStrings.add,
                        ),
                        style: AppStyles.caption12Regular.copyWith(
                          color: ColorManager.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: ColorManager.primary,
                        ),
                      ),
                    ),
                    // TextUnderLineShared(
                    //   onTap: (){
                    //     myState((){
                    //       showPromoCode =! showPromoCode;
                    //     });
                    //   },
                    //    text: translate(showPromoCode? AppStrings.hide : AppStrings.add),
                    //   //  textColor: ColorManager.primary,
                    // )
                  ],
                ),
                AppPadding.p23.ph,
                if (showPromoCode)
                  TextFormShared(
                    initialValue: sl.call<PromoBloc>.call().code,
                    hintText: '',
                    onChanged: (value) {
                      myState(() {
                        sl.call<PromoBloc>.call().code = value.trim();
                      });
                    },
                    textInputAction: TextInputAction.done,
                    onSubmit: (_) {
                      sl.call<PromoBloc>.call().code.isNotEmpty && showPromoCode
                          ? sl.call<PromoBloc>.call().add(
                              ApplyPromoCode(
                                code: sl.call<PromoBloc>.call().code,
                                orderId: widget.orderId,
                              ),
                            )
                          : null;
                    },
                    suffixIcon: BlocConsumer<PromoBloc, PromoState>(
                      listener: (BuildContext context, PromoState state) {
                        if (state is ApplyPromoSuccess) {
                          showSnackBar(
                            buildContext: context,
                            message: 'Success Apply PromoCode',
                          );
                          myState(() {
                            showPromoCode = false;
                            sl.call<PromoBloc>.call().code = '';
                          });
                        } else if (state is ApplyPromoError) {
                          showSnackBar(
                            buildContext: context,
                            message:
                                Localizations.localeOf(context).languageCode ==
                                    'en'
                                ? state.errorModel!.en!
                                : state.errorModel!.ar!,
                          );
                        }
                      },
                      builder: (BuildContext context, PromoState state) {
                        if (state is ApplyPromoLoading) {
                          return SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const LoadingWidget(),
                          );
                        }
                        return GestureDetector(
                          onTap: () {
                            sl.call<PromoBloc>.call().code.isNotEmpty &&
                                    showPromoCode
                                ? sl.call<PromoBloc>.call().add(
                                    ApplyPromoCode(
                                      code: sl.call<PromoBloc>.call().code,
                                      orderId: widget.orderId,
                                    ),
                                  )
                                : null;
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 25.w,
                              vertical: 20.h,
                            ),
                            child: Text(
                              translate(AppStrings.apply),
                              style: AppStyles.caption12Regular.copyWith(
                                color: ColorManager.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
