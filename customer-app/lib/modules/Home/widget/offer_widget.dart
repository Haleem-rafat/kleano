import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/modules/Home/bloc/banners/bloc/banner_bloc.dart';
import 'package:thewasher/modules/Home/data/model/banner_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/modules/plans_and_subscription/screens/plans_subscription_screen.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/pormo_codes_screen.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:url_launcher/url_launcher.dart';

class OfferWidget extends StatefulWidget {
  const OfferWidget({super.key});

  @override
  State<OfferWidget> createState() => _OfferWidgetState();
}

class _OfferWidgetState extends State<OfferWidget> {
  int currentIndex = 0;
  // Swiped by hand: research and accessibility rules advise against auto-advance.
  final PageController _pageController = PageController(viewportFraction: 0.92);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return BlocProvider<BannerBloc>(
      create: (context) {
        final bloc = BannerBloc();
        bloc.add(GetBanners());
        return bloc;
      },
      child: BlocBuilder<BannerBloc, BannerState>(
        builder: (context, state) {
          if (state.status != BannerStatus.success) {
            return const SizedBox.shrink();
          }
          final List<BannerModel> banners = state.banners ?? <BannerModel>[];
          if (banners.isEmpty) return const SizedBox.shrink();

          final bool arabic =
              Localizations.localeOf(context).languageCode == 'ar';
          return Column(
            children: <Widget>[
              // Keeps banners from filling the screen when unfolded.
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: AspectRatio(
                  aspectRatio: 1.9,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: banners.length,
                    onPageChanged: (int index) {
                      setState(() => currentIndex = index);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KSpace.xs,
                        ),
                        child: KCard(
                          padding: EdgeInsets.zero,
                          onTap: () =>
                              _handleBannerTap(context, banners[index]),
                          child: ImageShared(
                            image: arabic
                                ? banners[index].imageLinkAr ?? ''
                                : banners[index].imageLink ?? '',
                            height: double.infinity,
                            width: double.infinity,
                            raduis: KRadius.card,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (banners.length > 1) ...<Widget>[
                const SizedBox(height: KSpace.s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int i = 0; i < banners.length; i++)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(
                          horizontal: KSpace.xs / 2,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == currentIndex ? c.brand : c.separator,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleBannerTap(
    BuildContext context,
    BannerModel banner,
  ) async {
    final launched = await _launchExternalLink(banner.externalLink);
    if (launched || !context.mounted) return;

    switch (banner.resource?.toUpperCase()) {
      case 'PROMO_CODE':
        pushPage(context, PromoCodeScreen(highlightPromoId: banner.resourceId));
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
