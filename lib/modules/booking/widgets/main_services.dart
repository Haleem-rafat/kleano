import 'package:thewasher/modules/booking/home_style.dart';
import 'package:flutter/material.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class MainServices extends StatefulWidget {
  final List<ServiceModel> mainServices;
  final Function(int index)? addOrRemoveMainServices;

  /// Tapping a wash opens its sheet (approved Home). Null keeps the selectable
  /// radio list, used for subscribers adding to a plan.
  final void Function(ServiceModel service, int index)? onOpen;
  const MainServices({
    super.key,
    required this.mainServices,
    this.addOrRemoveMainServices,
    this.onOpen,
  });

  @override
  State<MainServices> createState() => _MainServicesState();
}

class _MainServicesState extends State<MainServices> {
  static const double _largePhotoHeight = KSpace.xxxl * 5;

  void _onStyleChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    HomeStyleSetting.style.addListener(_onStyleChanged);
  }

  @override
  void dispose() {
    HomeStyleSetting.style.removeListener(_onStyleChanged);
    super.dispose();
  }

  Map<int, bool> expandedStates = {};

  Widget _buildDetailItem({
    required String icon,
    required String text,
    required KColors c,
    Color? color,
    Widget? suffix,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          height: 14,
          width: 14,
          colorFilter: color == null
              ? null
              : ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: KSpace.xs),
        Text(text, style: KType.footnote.copyWith(color: c.text)),
        if (suffix != null) ...[const SizedBox(width: 2), suffix],
      ],
    );
  }

  Widget _buildDescriptionItem(String text, KColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsetsDirectional.only(top: 6, end: KSpace.s),
            height: 4,
            width: 4,
            decoration: BoxDecoration(color: c.brand, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(text, style: KType.footnote.copyWith(color: c.text)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offersBloc = sl<OffersBloc>();
    return BlocBuilder<OffersBloc, OffersState>(
      bloc: offersBloc,
      builder: (context, state) {
        if (state is OffersInitial ||
            state is GetServicesLoading ||
            state is GetGuestServicesLoading) {
          return const KLoadingState();
        }

        if (widget.mainServices.isEmpty) {
          return const SizedBox();
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.mainServices.length,
          itemBuilder: (context, index) {
            final service = widget.mainServices[index];
            if (service.name == "1") {
              return const SizedBox.shrink();
            }
            final bool isSelected = offersBloc.cartServicesList.contains(
              service,
            );
            final List<dynamic>? description =
                service.description as List<dynamic>?;

            final KColors c = KColors.of(context);
            final bool large =
                HomeStyleSetting.style.value == HomeStyle.serviceFirst &&
                widget.onOpen != null;
            final bool expanded = expandedStates[index] == true;
            void toggle() {
              HapticFeedback.selectionClick();
              if (isSelected) {
                offersBloc.add(
                  DeleteServiceCart(
                    index: offersBloc.cartServicesList.indexOf(service),
                    service: service,
                  ),
                );
              } else {
                offersBloc.add(
                  AddServiceCart(
                    service: service,
                    selectedMainServiceIndex: index,
                  ),
                );
              }
            }

            // Design: CustomerHome — one card, brand ring when selected,
            // details behind a link instead of a nested box.
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: KSpace.s),
              child: Semantics(
                selected: isSelected,
                child: AnimatedContainer(
                  duration: KMotion.of(context, KMotion.fast),
                  decoration: ShapeDecoration(
                    color: c.surface,
                    shape: KRadius.shape(
                      BorderRadius.circular(KRadius.card),
                      side: BorderSide(
                        color: isSelected && widget.onOpen == null
                            ? c.brand
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    shadows: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      customBorder: KRadius.shape(
                        BorderRadius.circular(KRadius.card),
                      ),
                      onTap: widget.onOpen == null
                          ? toggle
                          : () {
                              HapticFeedback.selectionClick();
                              widget.onOpen!(service, index);
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(KSpace.m),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (large) ...<Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  KRadius.field,
                                ),
                                child: ImageShared(
                                  image: service.icon?.iconLink ?? '',
                                  height: _largePhotoHeight,
                                  width: double.infinity,
                                ),
                              ),
                              const SizedBox(height: KSpace.m),
                            ],
                            Row(
                              children: <Widget>[
                                if (!large) ...<Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      KRadius.field,
                                    ),
                                    child: ColoredBox(
                                      color: c.fill,
                                      child: ImageShared(
                                        image: service.icon?.iconLink ?? '',
                                        height: 64,
                                        width: 64,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: KSpace.m),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        service.name ?? '',
                                        style: KType.headline.copyWith(
                                          color: c.text,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: KSpace.xs),
                                      Wrap(
                                        spacing: KSpace.m,
                                        runSpacing: KSpace.xs,
                                        children: <Widget>[
                                          if (service.duration != null)
                                            _buildDetailItem(
                                              c: c,
                                              color: c.textSecondary,
                                              icon: AssetsManager.timeIconLogo,
                                              text:
                                                  "${service.duration} ${translate(service.durationUnit ?? '')}",
                                            ),
                                          _buildDetailItem(
                                            c: c,
                                            color: c.text,
                                            icon: AssetsManager.serviceCoinSvg,
                                            text: "${service.price ?? ''} ",
                                            suffix: SvgPicture.asset(
                                              AssetsManager.saudiRiyalSymbol,
                                              colorFilter: ColorFilter.mode(
                                                KColors.of(context).text,
                                                BlendMode.srcIn,
                                              ),
                                              height: 12,
                                              width: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: KSpace.s),
                                if (widget.onOpen != null)
                                  Icon(
                                    Directionality.of(context) ==
                                            TextDirection.rtl
                                        ? Icons.chevron_left_rounded
                                        : Icons.chevron_right_rounded,
                                    color: c.textSecondary,
                                  )
                                else
                                  AnimatedContainer(
                                    duration: KMotion.of(context, KMotion.fast),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? c.brand
                                            : c.separator,
                                        width: isSelected ? 7 : 2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (widget.onOpen == null &&
                                description?.isNotEmpty == true) ...<Widget>[
                              const SizedBox(height: KSpace.s),
                              Semantics(
                                button: true,
                                expanded: expanded,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => setState(
                                    () => expandedStates[index] = !expanded,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: KSpace.xs,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          translate('serviceDetails'),
                                          style: KType.footnote.copyWith(
                                            color: c.brand,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Icon(
                                          expanded
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons
                                                    .keyboard_arrow_down_rounded,
                                          size: 18,
                                          color: c.brand,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (expanded)
                                for (final dynamic item in description!)
                                  _buildDescriptionItem(
                                    item?.toString() ?? '',
                                    c,
                                  ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
