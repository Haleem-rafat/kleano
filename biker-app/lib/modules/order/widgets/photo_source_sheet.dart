import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_list_row.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';

/// Content of the "gallery or camera" sheet; show it with `showKSheet`.
class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({
    super.key,
    required this.title,
    required this.onGallery,
    required this.onCamera,
  });

  final String title;
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          style: KType.headline.copyWith(color: c.text),
        ),
        const SizedBox(height: KSpace.s),
        KListRow(
          leading: Icon(Icons.photo_library_outlined, color: c.brand),
          title: tr(context, AppStrings.chooseFromGallery),
          onTap: onGallery,
        ),
        Divider(height: 1, color: c.separator),
        KListRow(
          leading: Icon(Icons.photo_camera_outlined, color: c.brand),
          title: tr(context, AppStrings.takeAPhoto),
          onTap: onCamera,
        ),
        const SizedBox(height: KSpace.s),
        KButton(
          label: tr(context, AppStrings.cancel),
          variant: KButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
