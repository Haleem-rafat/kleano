import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../liquid_glass.dart';
import '../tokens.dart';

/// Platform search field: Apple's on iOS, Material 3 `SearchBar` on Android —
/// never an outlined form field.
class KSearchField extends StatelessWidget {
  const KSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
    this.autofocus = false,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    if (GlassTokens.useNative) {
      return CupertinoSearchTextField(
        controller: controller,
        autofocus: autofocus,
        placeholder: hint,
        style: KType.body.copyWith(color: c.text),
        onChanged: onChanged,
      );
    }
    return SearchBar(
      controller: controller,
      autoFocus: autofocus,
      hintText: hint,
      elevation: const WidgetStatePropertyAll<double>(0),
      backgroundColor: WidgetStatePropertyAll<Color>(c.fill),
      leading: Icon(Icons.search_rounded, color: c.textSecondary),
      onChanged: onChanged,
    );
  }
}
