import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_picker_field.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/modules/booking/home_style.dart';

/// The Settings field that switches the Home layout.
class HomeStylePicker extends StatelessWidget {
  const HomeStylePicker({super.key});

  String _label(HomeStyle style) => translate('homeStyle_${style.name}');

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeStyle>(
      valueListenable: HomeStyleSetting.style,
      builder: (BuildContext context, HomeStyle style, Widget? child) =>
          KPickerField<HomeStyle>(
            label: translate('homeStyle'),
            items: HomeStyle.values,
            itemLabel: _label,
            value: _label(style),
            onSelected: HomeStyleSetting.set,
          ),
    );
  }
}

/// The same choice as a row on Home, so versions can be compared in place.
/// Remove once a version is chosen.
class HomeStyleChips extends StatelessWidget {
  const HomeStyleChips({super.key});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return ValueListenableBuilder<HomeStyle>(
      valueListenable: HomeStyleSetting.style,
      builder: (BuildContext context, HomeStyle current, Widget? child) =>
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(KSpace.l, 0, KSpace.l, KSpace.m),
            child: Row(
              spacing: KSpace.s,
              children: <Widget>[
                for (final HomeStyle style in HomeStyle.values)
                  ChoiceChip(
                    label: Text(translate('homeStyle_${style.name}')),
                    selected: style == current,
                    showCheckmark: false,
                    selectedColor: c.brandTint,
                    backgroundColor: c.surface,
                    side: BorderSide(color: c.separator),
                    labelStyle: KType.footnote.copyWith(
                      color: style == current ? c.onBrandTint : c.text,
                    ),
                    onSelected: (_) => HomeStyleSetting.set(style),
                  ),
              ],
            ),
          ),
    );
  }
}
