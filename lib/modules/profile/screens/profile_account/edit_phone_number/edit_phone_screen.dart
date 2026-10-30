import 'dart:math' as math;

import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/profile/blocs/update_profile/update_profile_bloc.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/utilties/phone_number.dart';
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

  Future<void> _selectCountryCode() async {
    final CountryCode? code = await countryPicker.showPicker(context: context);
    if (!mounted) return;
    setState(() {
      countryCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final MediaQueryData mq = MediaQuery.of(context);
    return Scaffold(
      // The Save button is padded by the keyboard height itself.
      resizeToAvoidBottomInset: false,
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(translate(AppStrings.phoneNumber)),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: KSpace.xxl),
              KTextField(
                label: translate(AppStrings.phoneNumber),
                hint: translate(AppStrings.enterPhoneNumber),
                controller: updateProfileBloc!.phoneController,
                validator: validatorPhone,
                keyboardType: TextInputType.phone,
                autofillHints: const <String>[
                  AutofillHints.telephoneNumberNational,
                ],
                textInputAction: TextInputAction.done,
                inputFormatters: <TextInputFormatter>[
                  PhoneDigitsFormatter(),
                ],
                prefix: TextButton(
                  onPressed: _selectCountryCode,
                  child: Text(
                    countryCode?.dialCode ?? countryCodeSelected,
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(
                  bottom: math.max(mq.viewInsets.bottom, mq.viewPadding.bottom) +
                      KSpace.l,
                ),
                // TODO(kleano): saving a new number is not wired to the API
                // yet (unchanged from before the redesign).
                child: KButton(
                  label: translate(AppStrings.save),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
