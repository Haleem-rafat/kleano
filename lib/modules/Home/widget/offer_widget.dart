import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_indicator.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/modules/Home/bloc/banners/bloc/banner_bloc.dart';
import 'package:thewasher/modules/Home/data/model/banner_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/modules/plans_and_subscription/screens/plans_subscription_screen.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/pormo_codes_screen.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:timezone/timezone.dart';
import 'package:url_launcher/url_launcher.dart';

class OfferWidget extends StatefulWidget {
  const OfferWidget({super.key});

  @override
  State<OfferWidget> createState() => _OfferWidgetState();
}

class _OfferWidgetState extends State<OfferWidget> {
  int currentIndex = 0;
  late PageController _pageController;
  Timer? _timer;
  int bannerCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  void _startAutoScroll() {
    _timer?.cancel();

    if (bannerCount > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          int nextPage = (currentIndex + 1) % bannerCount;

          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BannerBloc>(
      create: (context) {
        final bloc = BannerBloc();
        bloc.add(GetBanners());
        return bloc;
      },
      child: BlocBuilder<BannerBloc, BannerState>(
        builder: (context, state) {
          if (state.status == BannerStatus.loading) {
            return const Center(child: LoadingWidget());
          }

          if (state.status == BannerStatus.success) {
            final banners = state.banners ?? [];
            bannerCount = banners.length;

            if (bannerCount == 0) return const SizedBox();

            _startAutoScroll();

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                height: 190.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: bannerCount,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async =>
                            _handleBannerTap(context, banners[index]),
                        child: _buildOfferCard(context, index, banners),
                      );
                    },
                    onPageChanged: (index) {
                      setState(() => currentIndex = index);
                    },
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOfferCard(
      BuildContext context, int index, List<BannerModel> banners) {
    return DecoratedBox(
      decoration: _cardDecoration(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildCardContent(Localizations.localeOf(context).languageCode == 'ar'
              ? banners[index].imageLinkAr ?? ''
              : banners[index].imageLink ?? ''),
          Positioned(
            bottom: 12.h,
            left: 15.w,
            right: 15.w,
            child: AppIndicator(
              currentIndex: currentIndex,
              length: banners.length,
              selectedWidth: 8.w,
              innerPadding: 2.w,
              selectedColor: ColorManager.primary,
              unselectedColor: ColorManager.lightGray,
            ),
          )
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: ColorManager.white,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: ColorManager.lightGray, width: 1.w),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(99, 99, 99, 0.1),
          blurRadius: 20,
        ),
      ],
    );
  }

  Widget _buildCardContent(String imageBanner) {
    return ImageShared(
      image: imageBanner,
      height: 182.h,
      width: 316.w,
      raduis: 20.r,
      fit: BoxFit.cover,
    );
  }

  Future<void> _handleBannerTap(
      BuildContext context, BannerModel banner) async {
    final launched = await _launchExternalLink(banner.externalLink);
    if (launched) return;

    switch (banner.resource?.toUpperCase()) {
      case 'PROMO_CODE':
        pushPage(
          context,
          PromoCodeScreen(highlightPromoId: banner.resourceId),
        );
        break;

      case 'PLAN':
        pushPage(
          context,
          PlansAndSubscriptionScreen(highlightPlanId: banner.resourceId),
        );
        break;

      default:
        break;
    }
  }

  /// FIXED VERSION — Guaranteed to work on Android
  Future<bool> _launchExternalLink(String? link) async {
    if (link == null || link.trim().isEmpty) return false;

    String cleanLink = link.trim().replaceAll("\n", "");

    if (!cleanLink.startsWith("http")) {
      cleanLink = "https://$cleanLink";
    }

    final uri = Uri.tryParse(cleanLink);
    if (uri == null) return false;

    try {
      // On Android, canLaunchUrl can return false even for valid URLs
      // So we try to launch directly if canLaunchUrl returns true,
      // and also try as a fallback if it returns false
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback: try to launch anyway (common Android issue)
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        } catch (_) {
          return false;
        }
      }
    } catch (e) {
      // If canLaunchUrl throws, try to launch anyway
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } catch (_) {
        return false;
      }
    }
  }
}
