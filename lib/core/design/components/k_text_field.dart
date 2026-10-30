import 'package:flutter/material.dart';

import '../tokens.dart';

/// The Kleano text field: label above, filled field (from the theme), clear
/// focus state, error text below, and a show/hide toggle for passwords.
class KTextField extends StatefulWidget {
  const KTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.autofillHints,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.prefix,
    this.focusNode,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// Leading content inside the field (e.g. a country code).
  final Widget? prefix;
  final FocusNode? focusNode;

  @override
  State<KTextField> createState() => _KTextFieldState();
}

class _KTextFieldState extends State<KTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(start: KSpace.xs, bottom: 6),
          child: Text(widget.label,
              style: KType.footnote.copyWith(color: c.textSecondary)),
        ),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _hidden,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          style: KType.body.copyWith(color: c.text),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefix,
            semanticCounterText: widget.label,
            suffixIcon: widget.obscure
                ? IconButton(
                    key: const ValueKey<String>('k-text-field-visibility'),
                    tooltip: _hidden ? 'Show' : 'Hide',
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: c.textSecondary,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
