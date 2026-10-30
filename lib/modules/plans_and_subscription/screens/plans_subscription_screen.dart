import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/plans_model.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/subscription_model.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/card_plan.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/info_plan_user/card_info_user_plan.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/shared/components/connection_error/connection_error_screen.dart';
import 'package:thewasher/shared/components/delayed_methods.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';

late LatLng location;

class PlansAndSubscriptionScreen extends StatefulWidget {
  final Profile? profile;
  final String? highlightPlanId;
  const PlansAndSubscriptionScreen({
    super.key,
    this.profile,
    this.highlightPlanId,
  });

  @override
  State<PlansAndSubscriptionScreen> createState() =>
      _PlansAndSubscriptionScreenState();
}

class _PlansAndSubscriptionScreenState
    extends State<PlansAndSubscriptionScreen> {
  List<Plan> plans = [];
  Subscription subscription = Subscription();
  late GeneralSingleton generalSingleton;
  bool startAnimation = false;
  final GlobalKey _highlightPlanKey = GlobalKey();
  bool _didScrollToHighlightedPlan = false;
  @override
  void initState() {
    super.initState();
    generalSingleton = GeneralSingleton();
    getPlanAndSubscriptionAboutUserType();
  }

  void getPlanAndSubscriptionAboutUserType() {
    if (AppShared.token.isNotEmpty) {
      sl<PlansAndSubscriptionBloc>().add(GetSubscriptionAndPlans(
        latitude: blcoPosition.latitude,
        longitude: blcoPosition.longitude,
        country: "saudi arabia",
      ));
      sl<PlansAndSubscriptionBloc>().add(GetSubscriptionUserByLocation(
          latitude: blcoPosition.latitude,
          longitude: blcoPosition.longitude,
          country: "saudi arabia"));
    } else {
      sl<PlansAndSubscriptionBloc>().add(GetAllPlansForGuest(
        latitude: blcoPosition.latitude,
        longitude: blcoPosition.longitude,
        country: "saudi arabia",
      ));
    }
  }

  void showCardPlanAnimation() {
    delayedExecution(context, const Duration(milliseconds: 300), () {
      setState(() {
        startAnimation = true;
      });
    });
  }

  @override
  void didUpdateWidget(covariant PlansAndSubscriptionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlightPlanId != widget.highlightPlanId) {
      _didScrollToHighlightedPlan = false;
    }
  }

  @override
  void dispose() {
    startAnimation = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: AppBarShared(
          titleAppBar: translate(AppStrings.subscriptionsPlans),
          isTextOnly: true,
        ),
      ),
      body: BlocConsumer<PlansAndSubscriptionBloc, PlansAndSubscriptionState>(
        listener: (BuildContext context, PlansAndSubscriptionState state) {
          if (state is PlansAndSubscriptioSuccessState) {
            plans = state.allPlans;
            subscription = state.subscription;
            showCardPlanAnimation();
          } else if (state is GetPlansSuccess) {
            plans = state.plans;
            showCardPlanAnimation();
          } else if (state is GetSubscriptionSuccess) {
            subscription = state.subscription;
          } else if (state is SubscriptioByLocationSuccessState) {
            subscription = state.subscription;
          } else if (state is GetSubscriptionFailed) {
            // showSnackBar(buildContext: context, message: state.error);
          }
        },
        builder: (context, state) {
          if (state is PlansAndSubscriptionLoadingState) {
            return const LoadingWidget();
          } else if (state is PlansAndSubscriptionConnectionError) {
            return Center(
              child: ConnectionErrorSharedScreen(
                  onPressed: getPlanAndSubscriptionAboutUserType),
            );
          }
          return BlocBuilder<PlansAndSubscriptionBloc,
              PlansAndSubscriptionState>(
            builder: (context, state) {
              // Show loading state
              if (state is GetPlansLoading) {
                return const LoadingWidget();
              }

              // Show error state when getting plans fails
              if (state is GetSubscriptionFailed) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      // Show user's plan if they have one
                      if (subscription.sId != null &&
                          subscription.sId!.isNotEmpty) ...[
                        CardInfoUserPlan(subscription: subscription),
                        SizedBox(
                            height:
                                100.h), // Add spacing between plan and error
                      ],
                      if (subscription.sId == null) ...[
                        SizedBox(
                            height:
                                220.h), // Add spacing between plan and error
                      ],

                      // Error widget
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Error Icon Container

                              Container(
                                width: 120.w,
                                height: 120.h,
                                decoration: BoxDecoration(
                                  color: ColorManager.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ColorManager.red.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.location_off_outlined,
                                  size: 60.sp,
                                  color: ColorManager.red,
                                ),
                              ),

                              SizedBox(height: 32.h),

                              // Error Title
                              Text(
                                translate(AppStrings
                                    .ourServicesAreNotAvailableInYourLocation),
                                textAlign: TextAlign.center,
                                style: AppStyles.title16Bold.copyWith(
                                  fontSize: 20.sp,
                                  color: ColorManager.black,
                                ),
                              ),

                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show user's plan if they have one, even if no available plans
              if (subscription.sId != null && subscription.sId!.isNotEmpty) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      CardInfoUserPlan(subscription: subscription),
                      if (plans.isNotEmpty)
                        ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            itemCount: plans.length,
                            itemBuilder: (context, index) {
                              print("total plans ${plans.length}");
                              return planAnimationCard(index);
                            })
                    ],
                  ),
                );
              }

              // Show plans when available (user has no current plan)
              if (plans.isNotEmpty) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: plans.length,
                          itemBuilder: (context, index) {
                            print("total plans ${plans.length}");
                            return planAnimationCard(index);
                          })
                    ],
                  ),
                );
              }

              return const SizedBox();
            },
          );
        },
      ),
    );
  }

  Widget planAnimationCard(int index) {
    final plan = plans[index];
    final bool isHighlighted =
        widget.highlightPlanId != null && widget.highlightPlanId == plan.sId;
    if (isHighlighted) {
      _scrollHighlightedPlanIntoView();
    }
    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 300 + (index * 300)),
      transform: Matrix4.translationValues(0, startAnimation ? 0 : 815.h, 0),
      child: CardOfPlan(
        key: isHighlighted ? _highlightPlanKey : null,
        plan: plan,
        userHaveAPlan: subscription.sId != null ? true : false,
        isHighlighted: isHighlighted,
      ),
    );
  }

  void _scrollHighlightedPlanIntoView() {
    if (_didScrollToHighlightedPlan) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _highlightPlanKey.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
      _didScrollToHighlightedPlan = true;
    });
  }
}
