import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_sheet.dart';
import 'package:thewhsherbiker/core/design/components/k_text_field.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/order/widgets/photo_source_sheet.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/widget/profile/biker_photo_widget.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';
import 'package:thewhsherbiker/utilties/validator.dart';

class UpdateBikerData extends StatefulWidget {
  const UpdateBikerData({super.key});

  @override
  State<UpdateBikerData> createState() => _UpdateBikerDataState();
}

class _UpdateBikerDataState extends State<UpdateBikerData> {
  late TextEditingController nameController;
  late final GlobalKey<FormState> _loginFormKey;
  late final ProfileBloc profileBloc;
  File? pick;

  @override
  void initState() {
    super.initState();
    profileBloc = context.read<ProfileBloc>();
    nameController = TextEditingController();
    _loginFormKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> pickImage(bool camera) async {
    final XFile? image;
    try {
      if (camera) {
        image = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxHeight: 200,
          maxWidth: 200,
          imageQuality: 20,
        );
      } else {
        image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxHeight: 200,
          maxWidth: 200,
          imageQuality: 20,
        );
      }

      if (image == null) return;

      final File imageTemp = File(image.path);

      setState(() => pick = imageTemp);
    } on PlatformException {}
  }

  Future<void> _updateBikerInfo() async {
    profileBloc.add(
      BikerProfileEdit(
        name: nameController.text.isEmpty
            ? profileBloc.profile.userName!
            : nameController.text.trim(),
        image: pick != null ? pick!.path : "",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        title: Text(
          tr(context, AppStrings.modifyPersonalData),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: AdaptiveContent(
        child: ListView(
          padding: const EdgeInsets.all(KSpace.l),
          children: <Widget>[
            BikerPhotoWidget(pick: pick, onTap: () => showActionSheet(context)),
            const SizedBox(height: KSpace.xxl),
            Form(
              key: _loginFormKey,
              child: KTextField(
                validator: validatorName,
                label: tr(context, AppStrings.name),
                hint: profileBloc.profile.userName!,
                keyboardType: TextInputType.name,
                autofillHints: const <String>[AutofillHints.name],
                controller: nameController,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildButtonSave(),
    );
  }

  Widget _buildButtonSave() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.all(KSpace.l),
      child: Padding(
        // Stays above the keyboard.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (BuildContext context, ProfileState state) {
            if (state is BikerProfileEditFailed) {
              showSnackBar(buildContext: context, message: state.error);
            } else if (state is BikerProfileEditSuccess) {
              pop(context);
            }
          },
          buildWhen: (ProfileState previous, ProfileState current) =>
              current is BikerProfileEditLoading ||
              current is BikerProfileEditSuccess ||
              current is BikerProfileEditFailed,
          builder: (BuildContext context, ProfileState state) => KButton(
            label: tr(context, AppStrings.save),
            loading: state is BikerProfileEditLoading,
            onPressed: _updateBikerInfo,
          ),
        ),
      ),
    );
  }

  void showActionSheet(BuildContext context) {
    showKSheet<void>(
      context: context,
      builder: (BuildContext context) => PhotoSourceSheet(
        title: tr(context, AppStrings.chooseYourPicture),
        onGallery: () {
          pop(context);
          pickImage(false);
        },
        onCamera: () {
          pop(context);
          pickImage(true);
        },
      ),
    );
  }
}
