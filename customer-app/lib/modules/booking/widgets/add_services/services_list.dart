import 'package:flutter/material.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/modules/booking/widgets/home/service_sheet.dart';
import 'package:thewasher/modules/booking/widgets/main_services.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';

class ServicesList extends StatefulWidget {
  const ServicesList({
    super.key,
    this.alwaysShowExtras = false,
    this.onContinue,
  });

  /// Continue in the Choose a wash sheet. Null shows extras inline instead.
  final VoidCallback? onContinue;

  /// Subscribers add extras to their plan without picking a main service;
  /// everyone else sees extras only after choosing one.
  final bool alwaysShowExtras;

  @override
  State<ServicesList> createState() => _ServicesListState();
}

class _ServicesListState extends State<ServicesList> {
  late final OffersBloc offersBloc;
  Map<int, bool> expandedStates = {};

  @override
  void initState() {
    super.initState();
    offersBloc = sl<OffersBloc>();
  }

  void _refreshServices() {
    final bool guestMode = AppShared.token.isEmpty || isGuestUser;

    if (guestMode) {
      final guestPosition = GeneralSingleton().currentPositionGuest;
      final guestCountry = GeneralSingleton().country ?? 'saudi arabia';

      if (guestPosition != null) {
        offersBloc.add(
          GetGuestServices(
            lat: guestPosition.latitude,
            lng: guestPosition.longitude,
            country: guestCountry,
          ),
        );
        offersBloc.add(
          GetGuestAddOns(
            lat: guestPosition.latitude,
            lng: guestPosition.longitude,
            country: guestCountry,
          ),
        );
      }
    } else {
      // Trigger refresh of services and add-ons for authenticated users
      offersBloc.add(
        GetServices(
          lat: blcoPosition.latitude,
          lng: blcoPosition.longitude,
          country: "saudi arabia",
        ),
      );
      offersBloc.add(
        GetAddOns(
          lat: blcoPosition.latitude,
          lng: blcoPosition.longitude,
          country: "saudi arabia",
        ),
      );
    }
  }

  bool _shouldShowLoading(OffersState state) {
    return state is OffersInitial ||
        state is GetServicesLoading ||
        state is GetGuestServicesLoading ||
        state is GetAddOnsLoading ||
        state is GetGuestAddOnsLoading;
  }

  Widget _buildExtraRow(
    KColors c,
    int index,
    ServiceModel extraService,
    bool isSelected,
    void Function(ServiceModel) toggle,
  ) {
    final List<dynamic>? description =
        extraService.description as List<dynamic>?;
    final bool expanded = expandedStates[index] == true;
    return Semantics(
      selected: isSelected,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          toggle(extraService);
        },
        child: Padding(
          padding: const EdgeInsets.all(KSpace.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(KRadius.field),
                    child: ColoredBox(
                      color: c.fill,
                      child: ImageShared(
                        image: extraService.icon?.iconLink ?? '',
                        height: 44,
                        width: 44,
                      ),
                    ),
                  ),
                  const SizedBox(width: KSpace.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          extraService.name ?? '',
                          style: KType.headline.copyWith(color: c.text),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                "${extraService.duration ?? ''} ${translate(extraService.durationUnit ?? '')} · ${extraService.price ?? ''}",
                                style: KType.footnote.copyWith(
                                  color: c.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 2),
                            SvgPicture.asset(
                              AssetsManager.saudiRiyalSymbol,
                              height: 11,
                              width: 11,
                              colorFilter: ColorFilter.mode(
                                c.textSecondary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Checkbox.adaptive(
                    value: isSelected,
                    activeColor: c.brand,
                    onChanged: (bool? _) => toggle(extraService),
                  ),
                ],
              ),
              if (description?.isNotEmpty == true) ...<Widget>[
                InkWell(
                  onTap: () =>
                      setState(() => expandedStates[index] = !expanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: KSpace.xs),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          translate(AppStrings.serviceDetails),
                          style: KType.footnote.copyWith(
                            color: c.brand,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: c.brand,
                        ),
                      ],
                    ),
                  ),
                ),
                if (expanded)
                  for (final dynamic item in description!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: KSpace.xs),
                      child: Text(
                        item?.toString() ?? '',
                        style: KType.footnote.copyWith(color: c.text),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void addOrRemoveServices(ServiceModel extraService) {
      if (offersBloc.cartServicesList.contains(extraService)) {
        int deleteIndex = offersBloc.cartServicesList.indexOf(extraService);
        offersBloc.add(
          DeleteServiceCart(index: deleteIndex, service: extraService),
        );
      } else {
        offersBloc.add(AddServiceCart(service: extraService));
      }
    }

    final KColors c = KColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KSpace.l),
      child: BlocBuilder<OffersBloc, OffersState>(
        bloc: offersBloc,
        builder: (context, state) {
          if (_shouldShowLoading(state)) {
            return widget.onContinue == null
                ? const KSkeleton.list(padding: EdgeInsets.zero)
                : const KSkeleton.grid(padding: EdgeInsets.zero);
          }

          // Handle empty services state
          if (state is EmptyServices || state is EmptyGuestServices) {
            return KEmptyState(
              icon: Icons.local_car_wash_outlined,
              title: translate(AppStrings.ourServicesNotAvailable),
              message: translate(AppStrings.noContent),
            );
          }

          // Handle error state
          if (state is GetServicesFailed || state is GetGuestServicesFailed) {
            return KErrorState(
              message: translate(AppStrings.defaultError),
              onRetry: _refreshServices,
            );
          }

          // Handle success state
          List<ServiceModel> mainServicesData = offersBloc.mainServices;
          List<ServiceModel> extraServicesData = offersBloc.extraServices;

          if (state is GetServicesSuccess) {
            mainServicesData = state.mainServices;
            extraServicesData = state.extraServices;
          } else if (state is GetGuestServicesSuccess) {
            mainServicesData = state.mainServices;
            extraServicesData = state.extraServices;
          }

          final bool mainSelected = mainServicesData.any(
            offersBloc.cartServicesList.contains,
          );
          final bool showExtras =
              extraServicesData.isNotEmpty &&
              widget.onContinue == null &&
              (widget.alwaysShowExtras || mainSelected);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Home shows this title on one line with See all, in the grid.
              if (widget.onContinue == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: KSpace.xs),
                  child: Text(
                    translate(AppStrings.chooseYourMainService),
                    style: KType.title.copyWith(color: c.text),
                  ),
                ),
              MainServices(
                mainServices: mainServicesData,
                onOpen: widget.onContinue == null
                    ? null
                    : (ServiceModel service, int index) {
                        offersBloc.add(
                          AddServiceCart(
                            service: service,
                            selectedMainServiceIndex: index,
                          ),
                        );
                        showServiceSheet(
                          context: context,
                          service: service,
                          onContinue: widget.onContinue!,
                        );
                      },
              ),
              AnimatedSize(
                duration: KMotion.of(context, KMotion.normal),
                curve: KMotion.curve,
                alignment: AlignmentDirectional.topStart,
                child: showExtras
                    ? Padding(
                        padding: const EdgeInsets.only(top: KSpace.l),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              translate(AppStrings.chooseYourExtraServices),
                              style: KType.title.copyWith(color: c.text),
                            ),
                            const SizedBox(height: KSpace.s),
                            KCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: <Widget>[
                                  for (
                                    int i = 0;
                                    i < extraServicesData.length;
                                    i++
                                  ) ...<Widget>[
                                    if (i > 0)
                                      Divider(
                                        height: 1,
                                        indent: 44 + 2 * KSpace.m,
                                        color: c.separator,
                                      ),
                                    _buildExtraRow(
                                      c,
                                      i,
                                      extraServicesData[i],
                                      offersBloc.cartServicesList.contains(
                                        extraServicesData[i],
                                      ),
                                      addOrRemoveServices,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          );
        },
      ),
    );
  }
}
