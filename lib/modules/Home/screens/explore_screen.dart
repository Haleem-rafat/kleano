import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/Home/widget/services_widget.dart';
import 'package:thewasher/modules/my_booking/widgets/empty_services_and_addons.dart';
import 'package:thewasher/modules/plans_and_subscription/screens/plans_subscription_screen.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const double _addOnsHeight = 200;
  static const double _addOnWidth = 148;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    Widget sectionTitle(String key) => Padding(
      padding: const EdgeInsets.fromLTRB(
        KSpace.xl,
        KSpace.xxl,
        KSpace.xl,
        KSpace.m,
      ),
      child: Text(translate(key), style: KType.title.copyWith(color: c.text)),
    );

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: const Text('Kleano'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            sectionTitle(AppStrings.offers),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KSpace.xl),
              child: KCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Image.asset(
                            AssetsManager.offerCar,
                            height: 96,
                            cacheHeight: 288,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: KSpace.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Subscribe Now',
                                style: KType.headline.copyWith(color: c.text),
                              ),
                              Text(
                                '& get 30% off',
                                style: KType.subhead.copyWith(color: c.brand),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: KSpace.s),
                    SvgPicture.asset(AssetsManager.offerBookingSvg),
                    const SizedBox(height: KSpace.m),
                    KButton(
                      label: translate(AppStrings.viewPlans),
                      variant: KButtonVariant.secondary,
                      onPressed: () {
                        pushPage(
                          context,
                          PlansAndSubscriptionScreen(
                            profile: sl.call<GetUserProfileBloc>.call().profile,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            sectionTitle(AppStrings.services),
            // ServicesWidget still sizes itself with the old scaled units, so
            // this keeps the same scaled height until it is restyled.
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 185 / 812,
              width: double.infinity,
              child: const ServicesWidget(),
            ),
            sectionTitle(AppStrings.addOns),
            SizedBox(
              height: _addOnsHeight,
              width: double.infinity,
              child: BlocBuilder<OffersBloc, OffersState>(
                bloc: sl<OffersBloc>(),
                builder: (BuildContext context, OffersState state) {
                  final OffersBloc offers = sl<OffersBloc>();
                  return ListView.separated(
                    itemCount: offers.addOnsList.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(width: KSpace.s),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: KSpace.xl,
                      vertical: KSpace.xs,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final addOn = offers.addOnsList[index];
                      final bool inCart = offers.cartAddOnsList.contains(addOn);
                      return SizedBox(
                        width: _addOnWidth,
                        child: KCard(
                          padding: const EdgeInsets.all(KSpace.m),
                          child: Column(
                            children: <Widget>[
                              ImageShared(
                                image: addOn.icon!.iconLink!,
                                height: 50,
                                width: 50,
                              ),
                              const SizedBox(height: KSpace.s),
                              Expanded(
                                child: Text(
                                  addOn.name!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: KType.footnote.copyWith(color: c.text),
                                ),
                              ),
                              KButton(
                                label: '+ ${addOn.price} ${AppStrings.sAR}',
                                variant: inCart
                                    ? KButtonVariant.primary
                                    : KButtonVariant.secondary,
                                icon: inCart ? Icons.check : null,
                                onPressed: () {
                                  if (AppShared.token.isNotEmpty) {
                                    if (inCart) {
                                      offers.add(
                                        DeleteExtraCart(
                                          index: offers.cartAddOnsList.indexOf(
                                            addOn,
                                          ),
                                          extra: addOn,
                                        ),
                                      );
                                    } else {
                                      offers.add(AddExtraCart(extra: addOn));
                                    }
                                  } else {
                                    AlertHelper.guestAlert(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            sectionTitle(AppStrings.recentWashes),
            BlocBuilder<OffersBloc, OffersState>(
              bloc: sl<OffersBloc>(),
              builder: (BuildContext context, OffersState state) {
                if (AppShared.token.isEmpty) {
                  return const Center(
                    child: EmptyScreen(
                      image: AssetsManager.emptyRecentWashesSvg,
                      text: AppStrings.noWashesYet,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: KSpace.xxxl),
          ],
        ),
      ),
      bottomNavigationBar: AppShared.token.isEmpty
          ? null
          : ColoredBox(
              color: c.surface,
              child: SafeArea(
                minimum: const EdgeInsets.all(KSpace.l),
                child: BlocBuilder<OffersBloc, OffersState>(
                  builder: (BuildContext context, OffersState state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${sl<OffersBloc>().cartServicesList.length} * services - ${sl<OffersBloc>().cartAddOnsList.length} * Add-ons',
                          style: KType.footnote.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(height: KSpace.xs),
                        Text(
                          'Total Pay : ${sl<OffersBloc>().total}',
                          style: KType.headline.copyWith(color: c.text),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }
}
