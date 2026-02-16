import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:durey/providers/admob_provider.dart';

/// Widget to display a banner ad
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final adMobService = ref.read(adMobServiceProvider);
    
    adMobService.loadBannerAd(
      onAdLoaded: (ad) {
        ref.read(bannerAdStateProvider.notifier).setLoaded(true);
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('Banner ad failed to load: $error');
        ref.read(bannerAdStateProvider.notifier).setLoaded(false);
      },
    );
  }

  @override
  void dispose() {
    ref.read(adMobServiceProvider).disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdLoaded = ref.watch(bannerAdStateProvider);
    final adMobService = ref.watch(adMobServiceProvider);

    if (!isAdLoaded || adMobService.bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: adMobService.bannerAd!.size.width.toDouble(),
      height: adMobService.bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: adMobService.bannerAd!),
    );
  }
}
