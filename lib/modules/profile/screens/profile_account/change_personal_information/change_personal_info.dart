import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_picker_field.dart';
import 'package:thewasher/core/design/components/k_sheet.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/blocs/update_profile/update_profile_bloc.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/modules/profile/data/models/update_profile_request.dart';
import 'package:thewasher/modules/profile/widgets/upload_user_photo.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/utilties/validator.dart';

class ChangePersonalInformation extends StatefulWidget {
  final Profile user;
  const ChangePersonalInformation({super.key, required this.user});

  @override
  State<ChangePersonalInformation> createState() =>
      _ChangePersonalInformationState();
}

class _ChangePersonalInformationState extends State<ChangePersonalInformation> {
  late List<String> genderType;
  late GeneralSingleton generalSingleton;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final TextEditingController _dobController = TextEditingController();
  String? _pickedGender;
  late UpdateProfileBloc updateProfileBloc;
  late String nameText;
  late String emailText;
  late String gender;
  final _signUpFormKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  String? dobText; // Display format (e.g., "Jan 15, 2000")
  String? dobApiFormat; // API format (yyyy-MM-dd)

  @override
  void initState() {
    nameText = widget.user.userName!;
    emailText = widget.user.email ?? "";
    gender = widget.user.gender != null ? widget.user.gender! : '----';

    // Initialize date of birth from user profile
    if (widget.user.dob != null && widget.user.dob!.isNotEmpty) {
      try {
        selectedDate = DateTime.parse(widget.user.dob!);
        // Format for display (e.g., "Jan 15, 2000")
        dobText = DateFormat('MMM dd, yyyy').format(selectedDate!);
        // Keep API format (yyyy-MM-dd)
        dobApiFormat = widget.user.dob;
      } catch (e) {
        selectedDate = null;
        dobText = null;
        dobApiFormat = null;
      }
    }

    _nameController = TextEditingController(text: nameText)
      ..addListener(() => nameText = _nameController.text);
    _emailController = TextEditingController(text: emailText)
      ..addListener(() => emailText = _emailController.text);
    _dobController.text = dobText ?? '';

    genderType = ['Male', 'Female'];
    generalSingleton = GeneralSingleton();
    updateProfileBloc = BlocProvider.of<UpdateProfileBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _showDatePicker(BuildContext context) {
    showKSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                KButton(
                  label: translate(AppStrings.cancel),
                  variant: KButtonVariant.text,
                  expand: false,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                KButton(
                  label: translate(AppStrings.save),
                  variant: KButtonVariant.text,
                  expand: false,
                  onPressed: () {
                    setState(() {
                      // Display format for UI
                      dobText = DateFormat(
                        'MMM dd, yyyy',
                        'en',
                      ).format(selectedDate!);
                      _dobController.text = dobText!;
                      // API format for backend
                      dobApiFormat = DateFormat(
                        'yyyy-MM-dd',
                        'en',
                      ).format(selectedDate!);
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            SizedBox(
              height: 216,
              child: CupertinoDatePicker(
                initialDateTime: selectedDate ?? DateTime(2000, 1, 1),
                mode: CupertinoDatePickerMode.date,
                maximumDate: DateTime.now(),
                minimumDate: DateTime(1900, 1, 1),
                onDateTimeChanged: (DateTime newDate) {
                  selectedDate = newDate;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void validationSaveButton() {
    if (widget.user.gender == null || widget.user.gender == '---') {
      if (_signUpFormKey.currentState!.validate()) {
        if (((nameText.trim().isNotEmpty) || (emailText.trim().isNotEmpty)) &&
            (generalSingleton.gender != '---' &&
                    generalSingleton.gender != null ||
                widget.user.gender != null)) {
          generalSingleton.userImage != null
              ? updateProfileBloc.add(
                  UpdateProfileEvent(
                    updateProfileRequest: UpdateProfileRequest(
                      userName: nameText.trim(),
                      email: emailText.trim(),
                      image: File(generalSingleton.userImage!.path),
                      gender: generalSingleton.gender != null
                          ? generalSingleton.gender!
                          : widget.user.gender!,
                      dob: dobApiFormat,
                    ),
                  ),
                )
              : updateProfileBloc.add(
                  UpdateProfileEvent(
                    updateProfileRequest: UpdateProfileRequest(
                      userName: nameText.trim(),
                      email: emailText.trim(),
                      gender: generalSingleton.gender != null
                          ? generalSingleton.gender!
                          : widget.user.gender!,
                      dob: dobApiFormat,
                    ),
                  ),
                );
        }
      }
    } else if (((nameText.trim().isNotEmpty) ||
            (emailText.trim().isNotEmpty)) &&
        (generalSingleton.gender != '---' && generalSingleton.gender != null ||
            widget.user.gender != null)) {
      generalSingleton.userImage != null
          ? updateProfileBloc.add(
              UpdateProfileEvent(
                updateProfileRequest: UpdateProfileRequest(
                  userName: nameText.trim(),
                  email: emailText.trim(),
                  image: File(generalSingleton.userImage!.path),
                  gender: generalSingleton.gender != null
                      ? generalSingleton.gender!
                      : widget.user.gender!,
                  dob: dobApiFormat,
                ),
              ),
            )
          : updateProfileBloc.add(
              UpdateProfileEvent(
                updateProfileRequest: UpdateProfileRequest(
                  userName: nameText.trim(),
                  email: emailText.trim(),
                  gender: generalSingleton.gender != null
                      ? generalSingleton.gender!
                      : widget.user.gender!,
                  dob: dobApiFormat,
                ),
              ),
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final bool hasGender = gender != '----';
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(translate(AppStrings.changePersonalInformation)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(KSpace.xl),
        children: <Widget>[
          UserPhoto(
            isEdit: true,
            userPhoto: widget.user.imageLink != null
                ? widget.user.imageLink!
                : 'null',
          ),
          const SizedBox(height: KSpace.xxl),
          Form(
            key: _signUpFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                KTextField(
                  label: translate(AppStrings.name),
                  hint: translate(AppStrings.username),
                  controller: _nameController,
                  validator: validatorName,
                  keyboardType: TextInputType.name,
                  autofillHints: const <String>[AutofillHints.name],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: KSpace.l),
                KTextField(
                  label: translate(AppStrings.email),
                  hint: 'info@kleanoapp.com',
                  controller: _emailController,
                  validator: validatorEmail,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const <String>[AutofillHints.email],
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: KSpace.l),
                KPickerField<String>(
                  label: translate(AppStrings.gender),
                  items: genderType,
                  itemLabel: (String item) => item,
                  value: _pickedGender ?? (hasGender ? gender : null),
                  placeholder: gender,
                  onSelected: (String val) {
                    setState(() {
                      _pickedGender = val;
                      generalSingleton.gender = val;
                    });
                  },
                ),
                const SizedBox(height: KSpace.l),
                // Read-only: tapping opens the date sheet.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showDatePicker(context),
                  child: AbsorbPointer(
                    child: KTextField(
                      label: translate(AppStrings.dateOfBirth),
                      hint: 'Select Date of Birth',
                      controller: _dobController,
                      prefix: Icon(Icons.calendar_today, color: c.brand),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpace.xxl),
          BlocConsumer<UpdateProfileBloc, UpdateProfileState>(
            listener: (BuildContext context, UpdateProfileState stateUpdate) {
              if (stateUpdate is UpdateProfileFailed) {
                showSnackBar(
                  buildContext: context,
                  message: Localizations.localeOf(context).languageCode == 'ar'
                      ? stateUpdate.error!.ar!
                      : stateUpdate.error!.en!,
                );
              } else if (stateUpdate is UpdateProfileSuccess) {
                BlocProvider.of<GetUserProfileBloc>(
                  context,
                ).add(GetUserProfileEvent());
                pop(context);
              }
            },
            builder: (BuildContext context, UpdateProfileState stateUpdate) {
              return KButton(
                label: translate(AppStrings.save),
                loading: stateUpdate is UpdateProfileLoading,
                onPressed: validationSaveButton,
              );
            },
          ),
        ],
      ),
    );
  }
}
