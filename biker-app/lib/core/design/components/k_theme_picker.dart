import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../k_theme_mode.dart';
import 'k_picker_field.dart';

/// The Settings field for Light, Dark or following the phone.
class KThemePicker extends StatelessWidget {
  const KThemePicker({super.key});

  String _label(ThemeMode mode) => translate(switch (mode) {
    ThemeMode.light => 'themeLight',
    ThemeMode.dark => 'themeDark',
    ThemeMode.system => 'themeSystem',
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: KThemeMode.mode,
      builder: (BuildContext context, ThemeMode mode, Widget? child) =>
          KPickerField<ThemeMode>(
            label: translate('appearance'),
            items: ThemeMode.values,
            itemLabel: _label,
            value: _label(mode),
            onSelected: KThemeMode.set,
          ),
    );
  }
}
