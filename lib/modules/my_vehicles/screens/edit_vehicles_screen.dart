import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:photo_view/photo_view.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/car_model/cars_bloc.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
import 'package:thewasher/modules/my_vehicles/data/model/vehicles_model.dart';
import 'package:thewasher/modules/my_vehicles/widget/car_brands.dart';
import 'package:thewasher/modules/my_vehicles/widget/car_model_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewasher/modules/my_vehicles/widget/edit_car_title.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class EditVehiclesScreen extends StatefulWidget {
  final bool create;
  final VehiclesModel? vehicleData;
  EditVehiclesScreen({Key? key, required this.create, this.vehicleData})
      : super(key: key);

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
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0.r))),
              contentPadding: EdgeInsets.zero,
              content: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                  minHeight: 200.h,
                  minWidth: 280.w,
                ),
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Header with icon
                        Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Icon(
                            Icons.add_photo_alternate,
                            size: 30.sp,
                            color: ColorManager.primary,
                          ),
                        ),
                        AppPadding.p8.ph,
                        Text(
                          translate("makeChoice"),
                          style: AppStyles.title16Bold.copyWith(
                            color: ColorManager.darkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppPadding.p4.ph,
                        Text(
                          "Select an image source",
                          style: AppStyles.title16Regular.copyWith(
                            color: ColorManager.medGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppPadding.p16.ph,
                        // Camera option
                        Container(
                          width: double.infinity,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: ColorManager.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: () {
                                pickImage(true);
                                pop(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 24.sp,
                                    color: ColorManager.primary,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    translate("camera"),
                                    style: AppStyles.title16Medium.copyWith(
                                      color: ColorManager.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        AppPadding.p8.ph,
                        // Gallery option
                        Container(
                          width: double.infinity,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: ColorManager.darkGrey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: () {
                                pickImage(false);
                                pop(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo_library,
                                    size: 24.sp,
                                    color: ColorManager.primary,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    translate("gallery"),
                                    style: AppStyles.title16Medium.copyWith(
                                      color: ColorManager.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  void _showImageOptionsDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0.r))),
              contentPadding: EdgeInsets.zero,
              content: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                  minHeight: 240.h,
                  minWidth: 280.w,
                ),
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Header with icon
                        Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Icon(
                            Icons.image,
                            size: 30.sp,
                            color: ColorManager.primary,
                          ),
                        ),
                        AppPadding.p12.ph,
                        Text(
                          "Image Options",
                          style: AppStyles.title16Bold.copyWith(
                            color: ColorManager.darkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppPadding.p4.ph,
                        Text(
                          "Choose what you want to do",
                          style: AppStyles.title16Regular.copyWith(
                            color: ColorManager.medGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppPadding.p16.ph,
                        // View Full Screen option
                        Container(
                          width: double.infinity,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: ColorManager.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: () {
                                pop(context);
                                _showFullScreenImage(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: 24.sp,
                                    color: ColorManager.primary,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    "View Full Screen",
                                    style: AppStyles.title16Medium.copyWith(
                                      color: ColorManager.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        AppPadding.p8.ph,
                        // Pick Another Image option
                        Container(
                          width: double.infinity,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: ColorManager.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: () {
                                pop(context);
                                _showImagePickerDialog(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 24.sp,
                                    color: ColorManager.primary,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    "Pick Another Image",
                                    style: AppStyles.title16Medium.copyWith(
                                      color: ColorManager.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        AppPadding.p8.ph,
                        // Cancel option
                        Container(
                          width: double.infinity,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: ColorManager.primary,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: ColorManager.medGray.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: () {
                                pop(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Cancel",
                                    style: AppStyles.title16Medium.copyWith(
                                      color: ColorManager.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  void _showFullScreenImage(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.8),
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

  setControllers() {
    carModelController.text = widget.vehicleData!.model!;
    carPlateController.text = widget.vehicleData!.plateNumber!;
    carBrandController.text = widget.vehicleData!.brand!;
    selectedColorName = widget.vehicleData!.color!;
    selectedColor = colorList.indexWhere(
        (element) => element.colorName == widget.vehicleData!.color!);
  }

  defaultControllers() {
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

  getCarBrandInfo() {
    context.read<CarsBloc>().add(GetCarBrands());
  }

  createNewCar() {
    sl<VehiclesBloc>().add(CreateNewCar(
        context: context,
        brand: carBrandController.text,
        model: carModelController.text,
        plateNumber: carPlateController.text,
        color: selectedColorName,
        carImage: pick != null ? pick!.path : ""));
  }

  editCar() {
    sl<VehiclesBloc>().add(UpdateCar(
        context: context,
        id: widget.vehicleData!.sId!,
        brand: carBrandController.text,
        model: carModelController.text,
        plateNumber: carPlateController.text,
        color: selectedColorName,
        carImage: pick != null ? pick!.path : ""));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.lightStatusBarIconsWithTransparentColorStyle,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size(AppSize.s375, 60.h),
          child: AppBarShared(
            titleAppBar: widget.create
                ? translate(AppStrings.addNewVehicles)
                : translate(AppStrings.selectYourVehicles),
            isTextOnly: false,
          ),
        ),
        body: GestureDetector(
          onTap: () {
            // Unfocus all fields to close any open dropdowns
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppPadding.p24.ph,
                editCarTitle(AppStrings.uploadCarPhoto),
                AppPadding.p18.ph,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: InkWell(
                    onTap: () {
                      // Check if there's already an image
                      bool hasImage = pick != null ||
                          (!widget.create &&
                              widget.vehicleData?.imageLink?.isNotEmpty ==
                                  true);

                      if (hasImage) {
                        _showImageOptionsDialog(context);
                      } else {
                        _showImagePickerDialog(context);
                      }
                    },
                    child: DottedBorder(
                      dashPattern: const [4, 3, 1, 0],
                      borderType: BorderType.RRect,
                      color: ColorManager.darkGrey,
                      radius: Radius.circular(24.r),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        constraints: BoxConstraints(
                          maxHeight: 120.h,
                          maxWidth: double.infinity,
                          minHeight: 80.h,
                          minWidth: 120.w,
                        ),
                        child: AspectRatio(
                          aspectRatio:
                              1.2, // Slightly wider than square for better car photos
                          child: !widget.create && pick == null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(24.r),
                                  child: widget.vehicleData!.imageLink!.isEmpty
                                      ? Icon(
                                          Icons.image_outlined,
                                          size: 48.sp,
                                          color: ColorManager.darkGrey,
                                        )
                                      : Image.network(
                                          widget.vehicleData!.imageLink!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.image_outlined,
                                              size: 48.sp,
                                              color: ColorManager.darkGrey,
                                            );
                                          },
                                        ),
                                )
                              : pick == null
                                  ? Icon(
                                      Icons.image_outlined,
                                      size: 48.sp,
                                      color: ColorManager.darkGrey,
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(24.r),
                                      child: Image.file(
                                        pick!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.image_outlined,
                                            size: 48.sp,
                                            color: ColorManager.darkGrey,
                                          );
                                        },
                                      ),
                                    ),
                        ),
                      ),
                    ),
                  ),
                ),
                AppPadding.p32.ph,
                Container(
                  key: carBrandKey,
                  child: CardBrandsWidget(
                    carBrandController: carBrandController,
                  ),
                ),
                Container(
                  key: carModelKey,
                  child: CarModelWidget(
                    carModelController: carModelController,
                  ),
                ),
                // _carModel(),
                16.verticalSpace,
                editCarTitle(AppStrings.carPlate),
                AppPadding.p8.ph,
                Padding(
                  key: carPlateKey,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: SizedBox(
                    width: 328.w,
                    height: 56.h,
                    child: editTextForm(
                      translate("hint3"),
                      carPlateController,
                      carPlateFocusNode,
                      inputFormatters: [CarPlateFormatter()],
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ),
                AppPadding.p32.ph,
                editCarTitle(AppStrings.carColor),
                AppPadding.p20.ph,
                Container(
                  color: ColorManager.thirdColor200,
                  height: 50.h,
                  child: ListView.separated(
                    itemCount: colorList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return 8.horizontalSpace;
                    },
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedColor = colorList[index].id!;
                                selectedColorName = colorList[index].colorName;
                              });
                            },
                            child: SvgPicture.asset(
                              AssetsManager.car,
                              height: 50.h,
                              width: 34.w,
                              color: colorList[index].color,
                            ),
                          ),
                          if (selectedColor == colorList[index].id)
                            Positioned(
                              top: 2,
                              right: 0,
                              child: Container(
                                height: 18.h,
                                width: 20.w,
                                decoration: const BoxDecoration(
                                    color: ColorManager.primary,
                                    shape: BoxShape.circle),
                                child: const Icon(
                                  Icons.check,
                                  color: ColorManager.white,
                                  size: 15,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: BlocConsumer<VehiclesBloc, VehiclesState>(
          bloc: sl<VehiclesBloc>(),
          listener: (context, VehiclesState state) {
            if (state is CreateNewCarError) {
              showSnackBar(
                buildContext: context,
                message: state.error!,
              );
            } else if (state is UpdateCarError) {
              showSnackBar(
                buildContext: context,
                message: state.error!,
              );
            } else if (state is CreateNewCarSuccess ||
                state is UpdateCarSuccess) {
              AlertHelper.updateCarAlert(context);
            }
          },
          builder: (context, VehiclesState state) {
            if (state is CreateNewCarLoading || state is UpdateCarLoading) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
                child: SizedBox(
                  height: 50.h,
                  child: const LoadingWidget(),
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
                child: ButtonsShared(
                  onPressed: () {
                    if (carModelController.text.isNotEmpty &&
                        carPlateController.text.isNotEmpty &&
                        carBrandController.text.isNotEmpty) {
                      FocusScope.of(context).unfocus();
                      widget.create ? createNewCar() : editCar();
                    } else {
                      showSnackBar(
                        buildContext: context,
                        message:
                            Localizations.localeOf(context).languageCode == "ar"
                                ? "فضلاً اكمال باقي البيانات"
                                : "Please complete the remaining data",
                      );
                    }
                  },
                  text: widget.create
                      ? translate(AppStrings.addVehicle)
                      : translate(AppStrings.save),
                ),
              );
            }
          },
        ),
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
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
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
                          Colors.black.withOpacity(0.7),
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
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
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
                          Colors.black.withOpacity(0.7),
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
