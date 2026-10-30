import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/screens/home_screen.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class AddressCheckScreen extends StatefulWidget {
  const AddressCheckScreen({super.key});

  @override
  State<AddressCheckScreen> createState() => _AddressCheckScreenState();
}

class _AddressCheckScreenState extends State<AddressCheckScreen>
    with SingleTickerProviderStateMixin {
  bool _hasNavigated = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // Get saved locations when screen loads - delayed to show animation
    Future.delayed(const Duration(milliseconds: 800), () {
      sl<LocationBloc>().add(GetSavedLocation());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateBasedOnAddress() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    if (!mounted) return;

    final locationBloc = sl<LocationBloc>();
    if (locationBloc.savedLocation.isEmpty) {
      // User doesn't have saved address - navigate to home to add address
      popALlAndPushPage(context, const HomeScreen(isFromSignUp: true));
    } else {
      // User has saved address - navigate to main screen
      popALlAndPushPage(context, const MainNavigationScreen(selectedIndex: 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state is GetSavedLocationSuccess ||
            state is GetSavedLocationFailed) {
          // Add minimum display time to ensure user sees the checking screen
          Future.delayed(const Duration(milliseconds: 1500), () {
            _navigateBasedOnAddress();
          });
        }
      },
      child: AnnotatedRegion(
        value: AppStyles.lightStatusBarIconsWithTransparentColorStyle,
        child: Scaffold(
          backgroundColor: ColorManager.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Location Icon with Background
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: ColorManager.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              size: 70,
                              color: ColorManager.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Loading Indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(ColorManager.primary),
                        strokeWidth: 3.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      translate(AppStrings.checkingYourAddress),
                      style: const TextStyle(
                        color: ColorManager.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      translate(AppStrings.verifyingSavedLocation),
                      style: TextStyle(
                        color: ColorManager.medGray,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
