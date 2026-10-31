import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/data/model/address_model.dart';

/// One saved address in a grouped list: its name, the address below it and
/// the app's location icon (brand-coloured when it is the default).
class SavedLocationRow extends StatelessWidget {
  const SavedLocationRow({
    super.key,
    required this.location,
    this.trailing,
    this.onTap,
  });

  /// Lines up the row hairline with the row text.
  static const double dividerIndent = KSpace.l + 24 + KSpace.m;

  final AddressModel location;
  final Widget? trailing;
  final VoidCallback? onTap;

  static String title(AddressModel location) {
    if (location.savedName?.isNotEmpty == true) return location.savedName!;
    if (location.streetName?.isNotEmpty == true) return location.streetName!;
    return translate(AppStrings.savedLocation);
  }

  static String subtitle(AddressModel location) => <String?>[
    location.streetName,
    location.subAdministrativeArea,
    location.country,
  ].where((String? part) => part?.isNotEmpty == true).join(', ');

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final String details = subtitle(location);
    return KListRow(
      leading: SvgPicture.asset(
        AssetsManager.locationIconLogo,
        colorFilter: ColorFilter.mode(
          location.isDefault == true ? c.brand : c.textSecondary,
          BlendMode.srcIn,
        ),
      ),
      title: title(location),
      subtitle: details.isEmpty ? null : details,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
