import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';

/// The biker's photo with a camera badge: the [pick]ed file, else the saved one.
class BikerPhotoWidget extends StatelessWidget {
  final File? pick;
  final Function() onTap;
  const BikerPhotoWidget({super.key, this.pick, required this.onTap});

  static const double _size = KSpace.xxxl * 2 + KSpace.xl;

  Widget _file(BuildContext context, File file) => ClipOval(
    child: Image.file(
      file,
      width: _size,
      height: _size,
      cacheWidth: (_size * MediaQuery.devicePixelRatioOf(context)).round(),
      fit: BoxFit.cover,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onTap(),
        child: SizedBox.square(
          dimension: _size,
          child: Stack(
            children: <Widget>[
              if (pick != null)
                _file(context, pick!)
              else
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (BuildContext context, ProfileState state) {
                    final ProfileBloc bloc = context.read<ProfileBloc>();
                    final File? localImageFile = bloc.getLocalImageFile();
                    if (localImageFile != null) {
                      return _file(context, localImageFile);
                    }
                    return HomeAvatar(
                      imageUrl: bloc.getUserImage(),
                      name: bloc.getUserName(),
                      size: _size,
                    );
                  },
                ),
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: SvgPicture.asset(
                  ImageAssets.cameraLogo,
                  width: KSpace.xxl,
                  height: KSpace.xxl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
