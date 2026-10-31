import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/screens/edit_vehicles_screen.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

/// The last completed wash with everything that would repeat.
class BookAgainCard extends StatelessWidget {
  const BookAgainCard({
    super.key,
    required this.order,
    required this.onTap,
    this.light = false,
  });

  /// White card with the price and a main button, for the Photo hero.
  final bool light;

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    const Color onBrand = Colors.white;
    final String car = <String?>[
      order.vehicle?.brand,
      order.vehicle?.model,
    ].where((String? part) => part?.isNotEmpty == true).join(' ');
    if (light) {
      return KCard(
        padding: const EdgeInsets.all(KSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.auto_awesome_outlined,
                  size: KSpace.l,
                  color: c.brand,
                ),
                const SizedBox(width: KSpace.xs),
                Expanded(
                  child: Text(
                    translate('bookAgain'),
                    style: KType.footnote.copyWith(
                      color: c.brand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (order.totalPrice != null)
                  Text(
                    '${order.totalPrice!.toStringAsFixed(0)} ${translate(AppStrings.sAR)}',
                    style: KType.headline.copyWith(color: c.text),
                  ),
              ],
            ),
            const SizedBox(height: KSpace.m),
            Text(
              order.washingServices?.firstOrNull?.name ?? '',
              style: KType.title.copyWith(color: c.text),
            ),
            Text(car, style: KType.subhead.copyWith(color: c.textSecondary)),
            const SizedBox(height: KSpace.m),
            KButton(label: translate('chooseATime'), onPressed: onTap),
          ],
        ),
      );
    }
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: c.brand,
        shape: KRadius.shape(BorderRadius.circular(KRadius.card)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              translate('bookAgain'),
              style: KType.footnote.copyWith(
                color: onBrand,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: KSpace.xs),
            Text(
              order.washingServices?.firstOrNull?.name ?? '',
              style: KType.title.copyWith(color: onBrand),
            ),
            Text(car, style: KType.subhead.copyWith(color: onBrand)),
            const SizedBox(height: KSpace.m),
            KButton(
              label: translate('chooseATime'),
              variant: KButtonVariant.secondary,
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// Switch cars with one tap; the choice carries into booking.
class HomeCarChips extends StatelessWidget {
  const HomeCarChips({super.key});

  @override
  Widget build(BuildContext context) {
    final VehiclesBloc bloc = sl<VehiclesBloc>();
    return BlocBuilder<VehiclesBloc, VehiclesState>(
      bloc: bloc,
      builder: (BuildContext context, VehiclesState state) {
        if (bloc.vehiclesList.isEmpty) return const SizedBox.shrink();
        final KColors c = KColors.of(context);
        return SizedBox(
          height: KSpace.tapTarget + KSpace.m,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(KSpace.l, 0, KSpace.l, KSpace.m),
            children: <Widget>[
              for (final vehicle in bloc.vehiclesList)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: KSpace.s),
                  child: ChoiceChip(
                    label: Text(
                      '${vehicle.brand ?? ''} ${vehicle.model ?? ''}',
                    ),
                    selected: bloc.selectedVehicle.sId == vehicle.sId,
                    selectedColor: c.brandTint,
                    backgroundColor: c.surface,
                    side: BorderSide(color: c.separator),
                    showCheckmark: false,
                    shape: const StadiumBorder(),
                    onSelected: (_) => bloc.add(SelectCar(vehicle: vehicle)),
                  ),
                ),
              ActionChip(
                label: Text(translate('addCar')),
                backgroundColor: c.surface,
                side: BorderSide(color: c.separator),
                shape: const StadiumBorder(),
                onPressed: () =>
                    pushPage(context, EditVehiclesScreen(create: true)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HomeReassurance extends StatelessWidget {
  const HomeReassurance({super.key, this.tiles = false});

  /// Icon tiles instead of plain text.
  final bool tiles;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    Widget item(String key) => Expanded(
      child: Text(
        translate(key),
        textAlign: TextAlign.center,
        style: KType.footnote.copyWith(color: c.textSecondary),
      ),
    );
    Widget tile(IconData icon, String key) => Expanded(
      child: KCard(
        padding: const EdgeInsets.all(KSpace.m),
        child: Column(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.brandTint,
              ),
              child: SizedBox.square(
                dimension: KSpace.xxxl + KSpace.xs,
                child: Icon(icon, size: KSpace.l, color: c.onBrandTint),
              ),
            ),
            const SizedBox(height: KSpace.s),
            Text(
              translate(key),
              textAlign: TextAlign.center,
              style: KType.caption.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
    if (tiles) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(KSpace.l, KSpace.l, KSpace.l, 0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: KSpace.s,
            children: <Widget>[
              tile(Icons.place_outlined, 'trustComeToYou'),
              tile(Icons.account_balance_wallet_outlined, 'trustPayment'),
              tile(Icons.chat_bubble_outline_rounded, 'trustSupport'),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(KSpace.l, KSpace.l, KSpace.l, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          item('trustComeToYou'),
          const SizedBox(width: KSpace.s),
          item('trustPayment'),
          const SizedBox(width: KSpace.s),
          item('trustSupport'),
        ],
      ),
    );
  }
}

class HomePlansCard extends StatelessWidget {
  const HomePlansCard({super.key, this.solid = false, this.gradient = false});

  /// Brand fill with a white action, instead of the soft tint.
  final bool solid;

  /// Brand gradient behind a solid card (implies [solid]'s white action).
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final bool strong = solid || gradient;
    final Color fg = strong ? c.surface : c.onBrandTint;
    return Padding(
      padding: const EdgeInsets.fromLTRB(KSpace.l, KSpace.l, KSpace.l, 0),
      child: Material(
        color: gradient
            ? Colors.transparent
            : solid
            ? c.brand
            : c.brandTint,
        shape: KRadius.shape(BorderRadius.circular(KRadius.card)),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: gradient
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: <Color>[c.brand, c.brandLight],
                  ),
                )
              : null,
          child: InkWell(
            onTap: () => popALlAndPushPage(
              context,
              const MainNavigationScreen(selectedIndex: 3),
            ),
            child: Padding(
              padding: const EdgeInsets.all(KSpace.l),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          translate('plansPromoTitle'),
                          style: KType.headline.copyWith(color: fg),
                        ),
                        Text(
                          translate('plansPromoBody'),
                          style: KType.subhead.copyWith(color: fg),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: KSpace.s),
                  DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: const StadiumBorder(),
                      color: strong ? c.surface : Colors.transparent,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: strong ? KSpace.l : 0,
                        vertical: strong ? KSpace.s : 0,
                      ),
                      child: Text(
                        translate('seePlans'),
                        style: KType.subhead.copyWith(
                          color: strong ? c.brand : fg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
