import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/plans_model.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/subscription_model.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/card_plan.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/info_plan_user/card_info_user_plan.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/shared/services/service_locator.dart';

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
  /// Room for the floating WhatsApp button that sits above the tab bar.
  static const double _floatingButtonClearance = KSpace.xxxl * 2 + KSpace.l;

  List<Plan> plans = <Plan>[];
  Subscription subscription = Subscription();
  final GlobalKey _highlightPlanKey = GlobalKey();
  bool _didScrollToHighlightedPlan = false;

  @override
  void initState() {
    super.initState();
    getPlanAndSubscriptionAboutUserType();
  }

  void getPlanAndSubscriptionAboutUserType() {
    if (AppShared.token.isNotEmpty) {
      sl<PlansAndSubscriptionBloc>().add(
        GetSubscriptionAndPlans(
          latitude: blcoPosition.latitude,
          longitude: blcoPosition.longitude,
          country: "saudi arabia",
        ),
      );
      sl<PlansAndSubscriptionBloc>().add(
        GetSubscriptionUserByLocation(
          latitude: blcoPosition.latitude,
          longitude: blcoPosition.longitude,
          country: "saudi arabia",
        ),
      );
    } else {
      sl<PlansAndSubscriptionBloc>().add(
        GetAllPlansForGuest(
          latitude: blcoPosition.latitude,
          longitude: blcoPosition.longitude,
          country: "saudi arabia",
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant PlansAndSubscriptionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlightPlanId != widget.highlightPlanId) {
      _didScrollToHighlightedPlan = false;
    }
  }

  bool get _hasSubscription => subscription.sId?.isNotEmpty == true;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        automaticallyImplyLeading: false,
        title: Text(
          translate(AppStrings.subscriptionsPlans),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: BlocConsumer<PlansAndSubscriptionBloc, PlansAndSubscriptionState>(
        listener: (BuildContext context, PlansAndSubscriptionState state) {
          if (state is PlansAndSubscriptioSuccessState) {
            plans = state.allPlans;
            subscription = state.subscription;
          } else if (state is GetPlansSuccess) {
            plans = state.plans;
          } else if (state is GetSubscriptionSuccess) {
            subscription = state.subscription;
          } else if (state is SubscriptioByLocationSuccessState) {
            subscription = state.subscription;
          }
        },
        builder: (BuildContext context, PlansAndSubscriptionState state) {
          if (state is PlansAndSubscriptionLoadingState) {
            return const KSkeleton.list();
          }
          if (state is PlansAndSubscriptionConnectionError) {
            return KErrorState(
              message: translate(AppStrings.yourNotConnected),
              onRetry: getPlanAndSubscriptionAboutUserType,
            );
          }
          if (state is GetSubscriptionFailed) {
            final Widget notAvailable = KEmptyState(
              icon: Icons.location_off_outlined,
              title: translate(
                AppStrings.ourServicesAreNotAvailableInYourLocation,
              ),
            );
            if (!_hasSubscription) return notAvailable;
            return _scrollable(context, <Widget>[
              CardInfoUserPlan(subscription: subscription),
              notAvailable,
            ]);
          }
          if (!_hasSubscription && plans.isEmpty) {
            return const SizedBox.shrink();
          }
          return _scrollable(context, <Widget>[
            if (_hasSubscription) CardInfoUserPlan(subscription: subscription),
            for (final Plan plan in plans) _planCard(plan),
          ]);
        },
      ),
    );
  }

  /// A plain column, not a lazy list: there are only a few plans, and scrolling
  /// to a highlighted plan needs every card to be built.
  Widget _scrollable(BuildContext context, List<Widget> children) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: KSpace.s,
        bottom: MediaQuery.paddingOf(context).bottom + _floatingButtonClearance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _planCard(Plan plan) {
    final bool isHighlighted =
        widget.highlightPlanId != null && widget.highlightPlanId == plan.sId;
    if (isHighlighted) {
      _scrollHighlightedPlanIntoView();
    }
    return CardOfPlan(
      key: isHighlighted ? _highlightPlanKey : null,
      plan: plan,
      userHaveAPlan: subscription.sId != null,
      isHighlighted: isHighlighted,
    );
  }

  void _scrollHighlightedPlanIntoView() {
    if (_didScrollToHighlightedPlan) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? cardContext = _highlightPlanKey.currentContext;
      if (cardContext == null) return;
      Scrollable.ensureVisible(
        cardContext,
        duration: KMotion.of(cardContext, KMotion.slow),
        curve: KMotion.curve,
        alignment: 0.1,
      );
      _didScrollToHighlightedPlan = true;
    });
  }
}
