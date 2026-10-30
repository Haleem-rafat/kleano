import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../liquid_glass.dart';
import '../tokens.dart';
import 'k_list_row.dart';
import 'k_sheet.dart';

/// Picks one value from a (long) list: a field that opens a searchable sheet.
/// Replaces dropdowns everywhere — Apple and Material both pick from long
/// lists in a sheet, not an inline menu.
///
/// iOS: the sheet is Liquid Glass ([showKSheet]); Android: Material 3 sheet.
class KPickerField<T> extends StatelessWidget {
  const KPickerField({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
    this.value,
    this.placeholder,
    this.searchHint,
    this.loading = false,
  });

  final String label;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T> onSelected;

  /// Text of the current choice; empty or null shows [placeholder].
  final String? value;
  final String? placeholder;
  final String? searchHint;
  final bool loading;

  Future<void> _open(BuildContext context) async {
    final T? picked = await showKSheet<T>(
      context: context,
      builder: (BuildContext context) => _PickerSheet<T>(
        title: label,
        items: items,
        itemLabel: itemLabel,
        selected: value,
        searchHint: searchHint ??
            MaterialLocalizations.of(context).searchFieldLabel,
      ),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final bool empty = value == null || value!.isEmpty;
    final bool enabled = !loading && items.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsetsDirectional.only(start: KSpace.xs, bottom: 6),
          child: Text(label,
              style: KType.footnote.copyWith(color: c.textSecondary)),
        ),
        Semantics(
          button: true,
          label: label,
          value: empty ? null : value,
          child: Material(
            color: c.fill,
            shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(KRadius.field)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? () => _open(context) : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: KSpace.l),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          empty ? (placeholder ?? '') : value!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: KType.body.copyWith(
                              color: empty ? c.textSecondary : c.text),
                        ),
                      ),
                      if (loading)
                        const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(Icons.unfold_more_rounded,
                            color: enabled
                                ? c.textSecondary
                                : c.textSecondary.withValues(alpha: 0.4)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.selected,
    required this.searchHint,
  });

  final String title;
  final List<T> items;
  final String Function(T item) itemLabel;
  final String? selected;
  final String searchHint;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final List<T> shown = _query.isEmpty
        ? widget.items
        : widget.items
            .where((T i) => widget
                .itemLabel(i)
                .toLowerCase()
                .contains(_query.toLowerCase()))
            .toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(widget.title,
              textAlign: TextAlign.center,
              style: KType.headline.copyWith(color: c.text)),
          const SizedBox(height: KSpace.m),
          // Platform search field: Apple's on iOS, Material 3 SearchBar on
          // Android — never an outlined form field.
          if (GlassTokens.useNative)
            CupertinoSearchTextField(
              autofocus: widget.items.length > 12,
              placeholder: widget.searchHint,
              style: KType.body.copyWith(color: c.text),
              onChanged: (String v) => setState(() => _query = v.trim()),
            )
          else
            SearchBar(
              autoFocus: widget.items.length > 12,
              hintText: widget.searchHint,
              elevation: const WidgetStatePropertyAll<double>(0),
              backgroundColor: WidgetStatePropertyAll<Color>(c.fill),
              leading: Icon(Icons.search_rounded, color: c.textSecondary),
              onChanged: (String v) => setState(() => _query = v.trim()),
            ),
          const SizedBox(height: KSpace.s),
          Expanded(
            child: ListView.separated(
              itemCount: shown.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, indent: KSpace.l, color: c.separator),
              itemBuilder: (BuildContext context, int i) {
                final String text = widget.itemLabel(shown[i]);
                final bool on = text == widget.selected;
                return KListRow(
                  title: text,
                  trailing: on
                      ? Icon(Icons.check_rounded, color: c.brand)
                      : null,
                  onTap: () => Navigator.of(context).pop(shown[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
