import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:durey/core/ads/admob_config.dart';

/// Service class for Google Mobile Ads operations
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  /// Initialize Google Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    
    // Optional: Set request configuration
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: ['YOUR_TEST_DEVICE_ID'], // Add your test device IDs
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
      ),
    );
  }

  // Banner Ad Methods
  Future<void> loadBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) async {
    _bannerAd = BannerAd(
      adUnitId: AdMobConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
          onAdFailedToLoad(ad, error);
        },
      ),
    );

    await _bannerAd!.load();
  }

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  // Interstitial Ad Methods
  Future<void> loadInterstitialAd({
    required Function(InterstitialAd ad) onAdLoaded,
    required Function(LoadAdError error) onAdFailedToLoad,
  }) async {
    await InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          onAdLoaded(ad);

          // Set full screen content callback
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  // Rewarded Ad Methods
  Future<void> loadRewardedAd({
    required Function(RewardedAd ad) onAdLoaded,
    required Function(LoadAdError error) onAdFailedToLoad,
  }) async {
    await RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          onAdLoaded(ad);

          // Set full screen content callback
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdLoaded = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(AdWithoutView ad, RewardItem reward) onUserEarnedReward,
  }) {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: onUserEarnedReward,
      );
    }
  }

  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  // Dispose all ads
  void disposeAllAds() {
    disposeBannerAd();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
