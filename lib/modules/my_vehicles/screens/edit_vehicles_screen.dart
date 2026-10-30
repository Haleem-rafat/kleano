import 'dart:io';

import 'package:flutter/material.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/components/k_sheet.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:photo_view/photo_view.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/car_model/cars_bloc.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
import 'package:thewasher/modules/my_vehicles/data/model/vehicles_model.dart';
import 'package:thewasher/modules/my_vehicles/widget/car_brands.dart';
import 'package:thewasher/modules/my_vehicles/widget/car_model_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewasher/modules/my_vehicles/widget/edit_car_title.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class EditVehiclesScreen extends StatefulWidget {
  final bool create;
  final VehiclesModel? vehicleData;
  const EditVehiclesScreen({super.key, required this.create, this.vehicleData});

  @override
  State<EditVehiclesScreen> createState() => _EditVehiclesScreenState();
}

class _EditVehiclesScreenState extends State<EditVehiclesScreen> {
  TextEditingController carModelController = TextEditingController();
  TextEditingController carPlateController = TextEditingController();
  TextEditingController carBrandController = TextEditingController();
  FocusNode carPlateFocusNode = FocusNode();
  ScrollController scrollController = ScrollController();
  final GlobalKey carPlateKey = GlobalKey();
  final GlobalKey carBrandKey = GlobalKey();
  final GlobalKey carModelKey = GlobalKey();
  String carModel = "";
  String hint = translate("hint1");
  File? pick;
  late int selectedColor;
  late String selectedColorName;
  List<String> cars = [];

  @override
  void dispose() {
    carModelController.dispose();
    carPlateController.dispose();
    carBrandController.dispose();
    carPlateFocusNode.dispose();
    scrollController.dispose();
    WidgetsBinding.instance.removeObserver(_KeyboardObserver(this));
    super.dispose();
  }

  Future pickImage(bool camera) async {
    final XFile? image;
    try {
      if (camera) {
        image = await ImagePicker()
            .pickImage(source: ImageSource.camera, imageQuality: 100);
      } else {
        image = await ImagePicker()
            .pickImage(source: ImageSource.gallery, imageQuality: 100);
      }

      if (image == null) return;

      final File imageTemp = File(image.path);

      setState(() => pick = imageTemp);
    } on PlatformException {
      // Handle platform exception silently
    }
  }

  void _showImagePickerDialog(BuildContext context) {
    showKSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: KSpace.s),
            child: Text(translate("makeChoice"),
                textAlign: TextAlign.center,
                style: KType.headline
                    .copyWith(color: KColors.of(sheetContext).text)),
          ),
          KListRow(
            title: translate("camera"),
            leading: const Icon(Icons.photo_camera_rounded),
            onTap: () {
              pop(sheetContext);
              pickImage(true);
            },
          ),
          KListRow(
            title: translate("gallery"),
            leading: const Icon(Icons.photo_library_rounded),
            onTap: () {
              pop(sheetContext);
              pickImage(false);
            },
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Hero(
          tag: 'car_image_${widget.vehicleData?.plateNumber ?? 'new'}',
          child: _EnhancedImageViewer(
            imageUrl:
                pick != null ? pick!.path : widget.vehicleData?.imageLink ?? '',
            carBrand: widget.vehicleData?.brand ?? 'Unknown',
            carModel: widget.vehicleData?.model ?? 'Model',
            isLocalImage: pick != null,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
    );
  }

  void setControllers() {
    carModelController.text = widget.vehicleData!.model!;
    carPlateController.text = widget.vehicleData!.plateNumber!;
    carBrandController.text = widget.vehicleData!.brand!;
    selectedColorName = widget.vehicleData!.color!;
    selectedColor = colorList.indexWhere(
        (element) => element.colorName == widget.vehicleData!.color!);
  }

  void defaultControllers() {
    selectedColor = colorList.first.id!;
    selectedColorName = colorList.first.colorName;
  }

  @override
  void initState() {
    !widget.create ? setControllers() : defaultControllers();
    super.initState();
    getCarBrandInfo();

    // Add listener to scroll when text field is focused
    carPlateFocusNode.addListener(() {
      if (carPlateFocusNode.hasFocus) {
        // Delay to ensure keyboard is fully shown
        Future.delayed(const Duration(milliseconds: 300), () {
          if (scrollController.hasClients) {
            final RenderBox? renderBox =
                carPlateKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final position = renderBox.localToGlobal(Offset.zero);
              final scrollOffset =
                  position.dy - 100; // Offset to show above keyboard
              scrollController.animateTo(
                scrollOffset.clamp(
                    0.0, scrollController.position.maxScrollExtent),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        });
      }
    });

    // Listen to keyboard visibility changes to handle dropdown positioning
    WidgetsBinding.instance.addObserver(_KeyboardObserver(this));
  }

  void getCarBrandInfo() {
    context.read<CarsBloc>().add(GetCarBrands());
  }

  void createNewCar() {
    sl<VehiclesBloc>().add(CreateNewCar(
        context: context,
        brand: carBrandController.text,
        model: carModelController.text,
        plateNumber: carPlateController.text,
        color: selectedColorName,
        carImage: pick != null ? pick!.path : ""));
  }

  void editCar() {
    sl<VehiclesBloc>().add(UpdateCar(
        context: context,
        id: widget.vehicleData!.sId!,
        brand: carBrandController.text,
        model: carModelController.text,
        plateNumber: carPlateController.text,
        color: selectedColorName,
        carImage: pick != null ? pick!.path : ""));
  }

  bool get _hasImage =>
      pick != null ||
      (!widget.create && (widget.vehicleData?.imageLink?.isNotEmpty ?? false));

  void _save() {
    if (carModelController.text.isNotEmpty &&
        carPlateController.text.isNotEmpty &&
        carBrandController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
      widget.create ? createNewCar() : editCar();
    } else {
      showSnackBar(
        buildContext: context,
        message: Localizations.localeOf(context).languageCode == "ar"
            ? "فضلاً اكمال باقي البيانات"
            : "Please complete the remaining data",
      );
    }
  }

  Widget _photo(KColors c) {
    final Widget image = pick != null
        ? Image.file(pick!, fit: BoxFit.cover)
        : _hasImage
            ? Image.network(widget.vehicleData!.imageLink!, fit: BoxFit.cover)
            : Center(
                child: SvgPicture.asset(
                  AssetsManager.car,
                  height: 56,
                  colorFilter:
                      ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
                ),
              );
    return KCard(
      padding: EdgeInsets.zero,
      onTap: _hasImage
          ? () => _showFullScreenImage(context)
          : () => _showImagePickerDialog(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Hero(
              tag: 'car_image_${widget.vehicleData?.plateNumber ?? 'new'}',
              child: ColoredBox(color: c.fill, child: image),
            ),
          ),
          KButton(
            label: translate(AppStrings.uploadCarPhoto),
            variant: KButtonVariant.text,
            onPressed: () => _showImagePickerDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _colours(KColors c) {
    return Wrap(
      spacing: KSpace.m,
      runSpacing: KSpace.m,
      children: <Widget>[
        for (final ColorType colour in colorList)
          Semantics(
            button: true,
            selected: selectedColor == colour.id,
            label: colour.colorName,
            child: GestureDetector(
              onTap: () => setState(() {
                selectedColor = colour.id!;
                selectedColorName = colour.colorName;
              }),
              child: SizedBox(
                width: 56,
                child: Column(
                  children: <Widget>[
                    AnimatedContainer(
                      duration: KMotion.of(context, KMotion.fast),
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == colour.id
                              ? c.brand
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colour.color,
                          border: Border.all(color: c.separator),
                        ),
                        child: selectedColor == colour.id
                            ? Icon(Icons.check_rounded,
                                size: 18,
                                color: (colour.color ?? Colors.white)
                                            .computeLuminance() >
                                        0.5
                                    ? Colors.black
                                    : Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: KSpace.xs),
                    Text(colour.colorName,
                        style: KType.caption.copyWith(color: c.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    Widget label(String key) => Padding(
          padding: const EdgeInsetsDirectional.only(
              start: KSpace.xs, bottom: KSpace.s, top: KSpace.xl),
          child: Text(translate(key),
              style: KType.footnote.copyWith(color: c.textSecondary)),
        );
    return Scaffold(
      backgroundColor: c.background,
      resizeToAvoidBottomInset: true,
      // The form scrolls under the floating glass button, like Apple's apps;
      // on a solid strip the glass has nothing to refract.
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(widget.create
            ? translate(AppStrings.addNewVehicles)
            : translate(AppStrings.editVehicle)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(KSpace.xl, KSpace.l, KSpace.xl,
              MediaQuery.viewPaddingOf(context).bottom + 96),
          children: <Widget>[
            _photo(c),
            const SizedBox(height: KSpace.l),
            KeyedSubtree(
              key: carBrandKey,
              child: CardBrandsWidget(carBrandController: carBrandController),
            ),
            KeyedSubtree(
              key: carModelKey,
              child: CarModelWidget(carModelController: carModelController),
            ),
            KeyedSubtree(
              key: carPlateKey,
              child: Padding(
                padding: const EdgeInsets.only(top: KSpace.l),
                child: KTextField(
                  label: translate(AppStrings.carPlate),
                  hint: translate("hint3"),
                  controller: carPlateController,
                  focusNode: carPlateFocusNode,
                  keyboardType: TextInputType.text,
                  inputFormatters: <TextInputFormatter>[CarPlateFormatter()],
                  textInputAction: TextInputAction.done,
                ),
              ),
            ),
            label(AppStrings.carColor),
            _colours(c),
          ],
        ),
      ),
      bottomNavigationBar: BlocConsumer<VehiclesBloc, VehiclesState>(
        bloc: sl<VehiclesBloc>(),
        listener: (BuildContext context, VehiclesState state) {
          if (state is CreateNewCarError) {
            showSnackBar(buildContext: context, message: state.error!);
          } else if (state is UpdateCarError) {
            showSnackBar(buildContext: context, message: state.error!);
          } else if (state is CreateNewCarSuccess ||
              state is UpdateCarSuccess) {
            AlertHelper.updateCarAlert(context);
          }
        },
        builder: (BuildContext context, VehiclesState state) {
          return SafeArea(
            minimum: const EdgeInsets.fromLTRB(
                KSpace.xl, KSpace.s, KSpace.xl, KSpace.l),
            child: KButton(
              label: widget.create
                  ? translate(AppStrings.addVehicle)
                  : translate(AppStrings.save),
              loading:
                  state is CreateNewCarLoading || state is UpdateCarLoading,
              onPressed: _save,
            ),
          );
        },
      ),
    );
  }
}

class _KeyboardObserver extends WidgetsBindingObserver {
  final _EditVehiclesScreenState _screenState;

  _KeyboardObserver(this._screenState);

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Check if keyboard is visible by checking the context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_screenState.mounted) {
        final keyboardHeight =
            MediaQuery.of(_screenState.context).viewInsets.bottom;
        if (keyboardHeight > 0) {
          // Keyboard is open - scroll to ensure dropdowns are visible
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_screenState.scrollController.hasClients) {
              // Scroll to show content above keyboard
              _screenState.scrollController.animateTo(
                _screenState.scrollController.position.maxScrollExtent * 0.3,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      }
    });
  }
}

class _EnhancedImageViewer extends StatefulWidget {
  final String imageUrl;
  final String carBrand;
  final String carModel;
  final bool isLocalImage;

  const _EnhancedImageViewer({
    required this.imageUrl,
    required this.carBrand,
    required this.carModel,
    required this.isLocalImage,
  });

  @override
  State<_EnhancedImageViewer> createState() => _EnhancedImageViewerState();
}

class _EnhancedImageViewerState extends State<_EnhancedImageViewer>
    with TickerProviderStateMixin {
  late PhotoViewController _photoViewController;
  late AnimationController _fadeController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();

    // Auto-hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _hideControls();
      }
    });
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _hideControls() {
    if (mounted) {
      setState(() {
        _showControls = false;
      });
      _fadeController.reverse();
    }
  }

  void _showControlsTemporarily() {
    if (mounted) {
      setState(() {
        _showControls = true;
      });
      _fadeController.forward();

      // Auto-hide again after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _hideControls();
        }
      });
    }
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25.r),
              onTap: () {
                onTap();
                HapticFeedback.lightImpact();
              },
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppStyles.caption12Regular.copyWith(
            color: Colors.white70,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main image viewer
          Center(
            child: GestureDetector(
              onTap: _showControlsTemporarily,
              child: PhotoView(
                imageProvider: widget.isLocalImage
                    ? FileImage(File(widget.imageUrl))
                    : NetworkImage(widget.imageUrl) as ImageProvider,
                controller: _photoViewController,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                initialScale: PhotoViewComputedScale.contained,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                loadingBuilder: (context, event) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: event == null
                              ? null
                              : event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes!,
                          color: ColorManager.primary,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading image...',
                          style: AppStyles.caption12Regular.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60.r,
                        color: Colors.white70,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Failed to load image',
                        style: AppStyles.body14Medium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Tap to retry',
                        style: AppStyles.caption12Regular.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top controls
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Opacity(
                opacity: _showControls ? _fadeController.value : 0.0,
                child: SafeArea(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.carBrand} ${widget.carModel}',
                                style: AppStyles.body14Medium.copyWith(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Tap to zoom • Pinch to zoom • Drag to pan',
                                style: AppStyles.caption12Regular.copyWith(
                                  color: Colors.white70,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25.r),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.close,
                                size: 24.r,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Bottom controls for zoom actions
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _showControls ? _fadeController.value : 0.0,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildZoomButton(
                          icon: Icons.zoom_out,
                          onTap: () {
                            _photoViewController.reset();
                          },
                          label: 'Fit',
                        ),
                        _buildZoomButton(
                          icon: Icons.zoom_in,
                          onTap: () {
                            final currentScale =
                                _photoViewController.scale ?? 1.0;
                            _photoViewController.scale = currentScale * 1.5;
                          },
                          label: 'Zoom In',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
