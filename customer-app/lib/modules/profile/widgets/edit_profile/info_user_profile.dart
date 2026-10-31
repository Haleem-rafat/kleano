import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';

class PersonalInformation extends StatelessWidget {
  final Profile user;
  const PersonalInformation({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    Widget row(IconData icon, String title, String? value) => KListRow(
      leading: Icon(icon, size: 20, color: c.brand),
      title: title,
      subtitle: value ?? '---',
    );
    final Widget divider = Divider(
      height: 1,
      indent: KSpace.l + 20 + KSpace.m,
      color: c.separator,
    );
    return Column(
      children: <Widget>[
        row(Icons.person_outline, translate(AppStrings.name), user.userName),
        divider,
        row(Icons.email_outlined, translate(AppStrings.email), user.email),
        divider,
        row(Icons.wc_outlined, translate(AppStrings.gender), user.gender),
        divider,
        row(Icons.cake_outlined, translate(AppStrings.dateOfBirth), user.dob),
      ],
    );
  }
}
