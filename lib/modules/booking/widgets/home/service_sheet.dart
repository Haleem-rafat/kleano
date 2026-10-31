import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_sheet.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/services/service_locator.dart';

/// Choose a wash: details, extras, live total and Continue. Closing without
/// continuing clears the selection, so Home never holds a hidden cart.
Future<void> showServiceSheet({
  required BuildContext context,
  required ServiceModel service,
  required VoidCallback onContinue,
}) async {
  final bool? continued = await showKSheet<bool>(
    context: context,
    builder: (BuildContext sheetContext) => _ServiceSheet(
      service: service,
      onContinue: () => Navigator.of(sheetContext).pop(true),
    ),
  );
  if (continued == true) {
    onContinue();
  } else {
    sl<OffersBloc>().add(ClearAllSelectedServices());
  }
}

class _ServiceSheet extends StatelessWidget {
  const _ServiceSheet({required this.service, required this.onContinue});

  final ServiceModel service;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final OffersBloc offers = sl<OffersBloc>();
    final List<dynamic> description =
        (service.description as List<dynamic>?) ?? const <dynamic>[];
    return BlocBuilder<OffersBloc, OffersState>(
      bloc: offers,
      builder: (BuildContext context, OffersState state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(KRadius.field),
                        child: ColoredBox(
                          color: c.fill,
                          child: ImageShared(
                            image: service.icon?.iconLink ?? '',
                            height: 56,
                            width: 56,
                          ),
                        ),
                      ),
                      const SizedBox(width: KSpace.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              service.name ?? '',
                              style: KType.title.copyWith(color: c.text),
                            ),
                            Text(
                              '${service.duration ?? ''} ${translate(service.durationUnit ?? '')}',
                              style: KType.subhead.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KSpace.m),
                  for (final dynamic line in description)
                    Padding(
                      padding: const EdgeInsets.only(bottom: KSpace.xs),
                      child: Text(
                        '$line',
                        style: KType.subhead.copyWith(color: c.textSecondary),
                      ),
                    ),
                  if (offers.extraServices.isNotEmpty) ...<Widget>[
                    const SizedBox(height: KSpace.s),
                    Text(
                      translate(AppStrings.chooseYourExtraServices),
                      style: KType.headline.copyWith(color: c.text),
                    ),
                    for (final ServiceModel extra in offers.extraServices)
                      CheckboxListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        activeColor: c.brand,
                        value: offers.cartServicesList.contains(extra),
                        title: Text(
                          extra.name ?? '',
                          style: KType.body.copyWith(color: c.text),
                        ),
                        subtitle: Text(
                          '${extra.duration ?? ''} ${translate(extra.durationUnit ?? '')} · ${extra.price ?? ''}',
                          style: KType.footnote.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        onChanged: (bool? _) {
                          final int i = offers.cartServicesList.indexOf(extra);
                          offers.add(
                            i >= 0
                                ? DeleteServiceCart(index: i, service: extra)
                                : AddServiceCart(service: extra),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: KSpace.m),
            KButton(
              label: '${translate(AppStrings.nextButton)} · ${offers.total}',
              onPressed: onContinue,
            ),
          ],
        );
      },
    );
  }
}
