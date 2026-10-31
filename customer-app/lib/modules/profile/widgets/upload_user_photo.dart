import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_sheet.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

class UserPhoto extends StatefulWidget {
  final bool isEdit;
  final String? userPhoto;

  /// Gives the initial when the app has no stored one.
  final String? name;
  const UserPhoto({
    super.key,
    required this.userPhoto,
    required this.isEdit,
    this.name,
  });

  @override
  State<UserPhoto> createState() => _UserPhotoState();
}

class _UserPhotoState extends State<UserPhoto> {
  static const double _size = 84;

  final ImagePicker picker = ImagePicker();
  GeneralSingleton generalSingleton = GeneralSingleton();
  late String userPhoto;
  void getGalleryImage() {
    picker
        .pickImage(
          source: ImageSource.gallery,
          maxHeight: 1000,
          maxWidth: 1000,
          imageQuality: 75,
        )
        .then((XFile? image) {
          if (image == null || !mounted) return;
          setState(() {
            generalSingleton.userImage = image;
            userPhoto = image.path;
          });
        });
  }

  void getCameraImage() {
    picker
        .pickImage(
          source: ImageSource.camera,
          maxHeight: 1000,
          maxWidth: 1000,
          imageQuality: 75,
        )
        .then((XFile? image) {
          if (image == null || !mounted) return;
          setState(() {
            generalSingleton.userImage = image;
            userPhoto = image.path;
          });
        });
  }

  @override
  void initState() {
    super.initState();
    userPhoto = widget.userPhoto != 'null'
        ? widget.userPhoto!
        : generalSingleton.userImage != null
        ? generalSingleton.userImage!.path
        : '';
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return GestureDetector(
      onTap: () {
        widget.isEdit ? showActionSheet(context) : null;
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            SizedBox.square(
              dimension: _size,
              child: CircleAvatar(
                backgroundColor: c.brandTint,
                child: userPhoto == generalSingleton.userImage?.path
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: FileImage(File(userPhoto)),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: const SizedBox.square(dimension: _size),
                      )
                    : userPhoto.isNotEmpty
                    ? ImageShared(
                        image: userPhoto,
                        height: _size,
                        width: _size,
                        raduis: _size / 2,
                      )
                    : Text(
                        generalSingleton.characterUserName ??
                            (widget.name ?? '')
                                .trim()
                                .characters
                                .take(1)
                                .toString()
                                .toUpperCase(),
                        style: KType.largeTitle.copyWith(color: c.onBrandTint),
                      ),
              ),
            ),
            if (widget.isEdit) SvgPicture.asset(AssetsManager.cameraIcon),
          ],
        ),
      ),
    );
  }

  void showActionSheet(BuildContext context) {
    showKSheet<void>(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(KSpace.s),
            child: Text(
              translate(AppStrings.chooseYourPicture),
              style: KType.headline.copyWith(color: KColors.of(context).text),
            ),
          ),
          KListRow(
            leading: Icon(
              Icons.photo_library_outlined,
              color: KColors.of(context).brand,
            ),
            title: translate(AppStrings.chooseFromGallery),
            onTap: () {
              pop(context);
              getGalleryImage();
            },
          ),
        ],
      ),
    );
  }
}
