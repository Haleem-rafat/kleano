import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/points/bloc/point_bloc.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/components/toggle_shared.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class UsingPoints extends StatefulWidget {
  final String orderId;
  final num points;
  const UsingPoints({
    super.key,
    required this.orderId,
    required this.points,
  });

  @override
  State<UsingPoints> createState() => _UsingPointsState();
}

class _UsingPointsState extends State<UsingPoints> {
  bool toggleSelected = false;
  bool checkPoints = false;

  @override
  void initState() {
    super.initState();
    sl<PointBloc>().add(GetUserPoints());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PointBloc, PointState>(
      listener: (context, state) {
        if (state is ApplyPointsFailed) {
          setState(() {
            toggleSelected = false;
            checkPoints = false;
          });
          showSnackBar(buildContext: context, message: state.errorModel!.en!);
        } else if (state is ApplyPointsSuccess) {
          setState(() {
            checkPoints = false;
          });
        }
      },
      builder: (context, state) {
        if (state is PointLoading) {
          return const LoadingWidget();
        } else if (state is PointLoaded) {
          checkPoints = sl<PointBloc>.call().pointResponse.points! >=
              sl<PointBloc>.call().pointResponse.redeemLimit!;
          return checkPoints
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppPadding.p18.ph,
                    Text(
                      translate(AppStrings.paymentMethod),
                      style: AppStyles.title16Bold
                          .copyWith(color: ColorManager.darkGrey),
                    ),
                    AppPadding.p8.ph,
                    Row(
                      children: <Widget>[
                        Text(
                          '${translate(AppStrings.points)} : ',
                          style: AppStyles.body14Medium
                              .copyWith(color: ColorManager.darkGrey),
                        ),
                        Text(
                          '${sl<PointBloc>.call().pointResponse.points!} ${translate(AppStrings.points).replaceFirst(RegExp(r'P'), 'p')}',
                          style: AppStyles.body14Medium
                              .copyWith(color: ColorManager.darkGrey),
                        ),
                        const Spacer(),
                        IgnorePointer(
                          ignoring: checkPoints ? false : true,
                          child: CupertinoSwitch(
                            value: toggleSelected,
                            activeColor: ColorManager.secondary,
                            onChanged: (bool value) {
                              setState(() {
                                toggleSelected = value;
                              });
                              if (value == true) {
                                sl<PointBloc>.call().add(ApplyPoints(
                                  orderId: widget.orderId,
                                ));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : const SizedBox();
        }

        return sl<PointBloc>().pointResponse.points != null
            ? Row(
                children: <Widget>[
                  Text(
                    '${translate(AppStrings.points)} : ',
                    style: AppStyles.body14Medium
                        .copyWith(color: ColorManager.darkGrey),
                  ),
                  Text(
                    '${sl<PointBloc>().pointResponse.points} ${translate(AppStrings.points).replaceFirst(RegExp(r'P'), 'p')}',
                    style: AppStyles.body14Medium
                        .copyWith(color: ColorManager.darkGrey),
                  ),
                  const Spacer(),
                  BlocListener<PointBloc, PointState>(
                    bloc: PointBloc(),
                    listener: (context, state) {
                      if (state is ApplyPointsFailed) {
                        setState(() {
                          toggleSelected = false;
                        });
                        showSnackBar(
                            buildContext: context,
                            message: state.errorModel!.en!);
                      }
                    },
                    child: IgnorePointer(
                        ignoring: checkPoints ? true : false,
                        child: CupertinoSwitch(
                          value: toggleSelected,
                          activeColor: ColorManager.secondary,
                          onChanged: (bool value) {
                            setState(() {
                              toggleSelected = value;
                            });
                            if (value == true) {
                              sl<PointBloc>.call().add(ApplyPoints(
                                orderId: widget.orderId,
                              ));
                            }
                          },
                        )),
                  ),
                ],
              )
            : const SizedBox();
      },
    );
  }
}
