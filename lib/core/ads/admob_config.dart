import 'dart:io';

/// AdMob configuration for ad unit IDs
class AdMobConfig {
  // Test Ad Unit IDs (use these for development)
  static String get testBannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static String get testInterstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  static String get testRewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  // Production Ad Unit IDs (replace with your actual IDs)
  static String get prodBannerAdUnitId => const String.fromEnvironment(
        'ADMOB_BANNER_ID',
        defaultValue: '',
      ).isEmpty
          ? testBannerAdUnitId
          : const String.fromEnvironment('ADMOB_BANNER_ID');

  static String get prodInterstitialAdUnitId => const String.fromEnvironment(
        'ADMOB_INTERSTITIAL_ID',
        defaultValue: '',
      ).isEmpty
          ? testInterstitialAdUnitId
          : const String.fromEnvironment('ADMOB_INTERSTITIAL_ID');

  static String get prodRewardedAdUnitId => const String.fromEnvironment(
        'ADMOB_REWARDED_ID',
        defaultValue: '',
      ).isEmpty
          ? testRewardedAdUnitId
          : const String.fromEnvironment('ADMOB_REWARDED_ID');

  // Use test IDs in debug mode, production IDs in release mode
  static String get bannerAdUnitId {
    return const bool.fromEnvironment('dart.vm.product')
        ? prodBannerAdUnitId
        : testBannerAdUnitId;
  }

  static String get interstitialAdUnitId {
    return const bool.fromEnvironment('dart.vm.product')
        ? prodInterstitialAdUnitId
        : testInterstitialAdUnitId;
  }

  static String get rewardedAdUnitId {
    return const bool.fromEnvironment('dart.vm.product')
        ? prodRewardedAdUnitId
        : testRewardedAdUnitId;
  }
}
