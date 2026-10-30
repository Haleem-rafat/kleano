import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/modules/profile/blocs/delete_user_account/delete_user_account_bloc.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

class DeleteUserAccount extends StatefulWidget {
  const DeleteUserAccount({Key? key}) : super(key: key);

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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      elevation: 0.6,
      backgroundColor: Colors.transparent,
      insetAnimationCurve: Curves.easeInOut,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, Function setState) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
              decoration: BoxDecoration(
                color: ColorManager.white,
                border: Border.all(color: ColorManager.darkGrey),
              ),
              padding: EdgeInsets.fromLTRB(
                29.w,
                54.17.h,
                29.w,
                45.17.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SvgPicture.asset(
                    AssetsManager.deleteAccount,
                    height: 72.h,
                    width: 68.5.w,
                  ),
                  AppPadding.p12.ph,
                  SizedBox(
                    width: 244.w,
                    child: Text(
                      translate(AppStrings.areYouSureYouWantToDelete),
                      textAlign: TextAlign.center,
                      style: AppStyles.subtext14Regular.copyWith(
                        color: ColorManager.thirdColor400,
                      ),
                    ),
                  ),
                  16.verticalSpace,
                  BlocConsumer<DeleteUserAccountBloc, DeleteUserAccountState>(
                    listener:
                        (BuildContext context, DeleteUserAccountState state) {
                      if (state is DeleteAccountSuccess) {
                        AppShared.setToken('');
                        AppShared.fcmToken = '';
                        AppShared.token = '';
                        GeneralSingleton().userImage = null;
                        popALlAndPushPage(
                            context,
                            ChooseRegisterView(
                            ));
                      } else if (state is DeleteAccountFailed) {
                        showSnackBar(
                            buildContext: context, message: state.error);
                      }
                    },
                    builder: (context, state) {
                      if (state is DeleteAccountLoading) {
                        return const LoadingWidget();
                      }
                      return ButtonsShared(
                          onPressed: () {
                            deleteUserAccountBloc.add(DeleteUserAccountEvent());
                          },
                          colorButton: ColorManager.red,
                          colorBorder: ColorManager.red,
                          text: translate(AppStrings.deleteAccount));
                    },
                  ),
                  32.5.verticalSpace,
                  GestureDetector(
                    onTap: () => pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      translate(AppStrings.cancel),
                      style: AppStyles.title16Medium.copyWith(
                        color: ColorManager.medGray,
                        decoration: TextDecoration.underline,
                        decorationColor: ColorManager.medGray,
                      ),
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}
