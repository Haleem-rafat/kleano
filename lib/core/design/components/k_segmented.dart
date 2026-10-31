import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../liquid_glass.dart';
import '../tokens.dart';

/// Segmented control: Apple's sliding segmented control on iOS, Material 3
/// single-select `SegmentedButton` on Android.
class KSegmented<T extends Object> extends StatelessWidget {
  const KSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  /// Value → label, in display order.
  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    if (GlassTokens.useNative) {
      return SizedBox(
        width: double.infinity,
        child: CupertinoSlidingSegmentedControl<T>(
          groupValue: selected,
          onValueChanged: (T? v) {
            if (v != null) onChanged(v);
          },
          children: <T, Widget>{
            for (final MapEntry<T, String> e in segments.entries)
              e.key: Padding(
                padding: const EdgeInsets.symmetric(vertical: KSpace.s),
                child: Text(
                  e.value,
                  style: KType.subhead.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          },
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        segments: <ButtonSegment<T>>[
          for (final MapEntry<T, String> e in segments.entries)
            ButtonSegment<T>(
              value: e.key,
              label: Text(
                e.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        selected: <T>{selected},
        onSelectionChanged: (Set<T> s) => onChanged(s.first),
      ),
    );
  }
}
