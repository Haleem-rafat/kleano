import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/profile/blocs/update_profile/update_profile_bloc.dart';
import 'package:thewasher/modules/profile/screens/profile_account/edit_phone_number/otp_edit_phone.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/components/text-form-shared.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/utilties/validator.dart';

class EditPhoneScreen extends StatefulWidget {
  final String countryCodeSelected;
  final String phoneNumber;
  const EditPhoneScreen({
    super.key,
    required this.countryCodeSelected,
    required this.phoneNumber,
  });

  @override
  State<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
  CountryCode? countryCode;
  final FlCountryCodePicker countryPicker = const FlCountryCodePicker();
  UpdateProfileBloc? updateProfileBloc;
  late String countryCodeSelected;

  @override
  void initState() {
    super.initState();
    updateProfileBloc = BlocProvider.of<UpdateProfileBloc>(context);
    countryCodeSelected = widget.countryCodeSelected;
    updateProfileBloc!.phoneController =
        TextEditingController(text: widget.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => pop(context),
          icon: const Icon(Icons.arrow_back_ios),
          color: ColorManager.primary,
        ),
        backgroundColor: ColorManager.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              50.ph,
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppPadding.p20.w, vertical: AppPadding.p8.h),
                child: Text(
                  translate(AppStrings.phoneNumber),
                  style: AppStyles.title16Regular
                      .copyWith(color: ColorManager.darkGrey),
                ),
              ),
              TextFormShared(
                controller: updateProfileBloc!.phoneController,
                hintText: translate("enterPhoneNumber"),
                validator: validatorPhone,
                textInputType: TextInputType.number,
                textInputAction: TextInputAction.done,
                textInputFormat: [
                  FilteringTextInputFormatter.deny(RegExp(r'^0+')),
                ],
                prefix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: InkWell(
                          onTap: () async {
                            final CountryCode? code = await countryPicker
                                .showPicker(context: context);
                            setState(() {
                              countryCode = code;
                            });
                            print(countryCode!.dialCode);
                          },
                          child: Row(
                            children: <Widget>[
                              countryCode != null
                                  ? Text(
                                      "(${countryCode!.dialCode}) ",
                                      style: AppStyles.title16Regular.copyWith(
                                          color: ColorManager.darkGrey),
                                    )
                                  : Text(
                                      countryCodeSelected,
                                      style: AppStyles.title16Regular.copyWith(
                                          color: ColorManager.darkGrey),
                                    ),
                              SvgPicture.asset(AssetsManager.arrowLogo)
                            ],
                          )),
                    ),
                    Container(
                      height: 23.h,
                      width: 1.w,
                      color: ColorManager.medGray,
                      margin: const EdgeInsets.only(top: 2),
                    ),
                    5.pw,
                  ],
                ),
              ),
              const Spacer(),
              ButtonsShared(
                  onPressed: () {
                    if (updateProfileBloc!.phoneController.text !=
                            widget.phoneNumber &&
                        updateProfileBloc!.phoneController.text
                            .trim()
                            .isNotEmpty) {}
                  },
                  text: translate(AppStrings.save)),
              AppPadding.p32.ph,
            ]),
      ),
    );
  }
}
