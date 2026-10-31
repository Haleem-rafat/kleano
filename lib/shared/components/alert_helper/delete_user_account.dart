import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/modules/profile/blocs/delete_user_account/delete_user_account_bloc.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

class DeleteUserAccount extends StatefulWidget {
  const DeleteUserAccount({super.key});

  @override
  State<DeleteUserAccount> createState() => _DeleteUserAccountState();
}

class _DeleteUserAccountState extends State<DeleteUserAccount> {
  late DeleteUserAccountBloc deleteUserAccountBloc;
  @override
  void initState() {
    super.initState();
    deleteUserAccountBloc = BlocProvider.of<DeleteUserAccountBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return KDialog(
      icon: SvgPicture.asset(AssetsManager.deleteAccount, height: 72),
      title: translate(AppStrings.areYouSureYouWantToDelete),
      actions: <Widget>[
        BlocConsumer<DeleteUserAccountBloc, DeleteUserAccountState>(
          listener: (BuildContext context, DeleteUserAccountState state) {
            if (state is DeleteAccountSuccess) {
              AppShared.setToken('');
              AppShared.fcmToken = '';
              AppShared.token = '';
              GeneralSingleton().userImage = null;
              popALlAndPushPage(context, ChooseRegisterView());
            } else if (state is DeleteAccountFailed) {
              showSnackBar(buildContext: context, message: state.error);
            }
          },
          builder: (BuildContext context, DeleteUserAccountState state) {
            return KButton(
              label: translate(AppStrings.deleteAccount),
              variant: KButtonVariant.destructive,
              loading: state is DeleteAccountLoading,
              onPressed: () {
                deleteUserAccountBloc.add(DeleteUserAccountEvent());
              },
            );
          },
        ),
        KButton(
          label: translate(AppStrings.cancel),
          variant: KButtonVariant.text,
          onPressed: () => pop(context),
        ),
      ],
    );
  }
}
