import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durey/services/admob_service.dart';

/// Provider for AdMobService
final adMobServiceProvider = Provider<AdMobService>((ref) {
  return AdMobService();
});

/// State notifier for banner ad loading state
class BannerAdState extends StateNotifier<bool> {
  BannerAdState() : super(false);

  void setLoaded(bool isLoaded) {
    state = isLoaded;
  }
}

/// Provider for banner ad loading state
final bannerAdStateProvider = StateNotifierProvider<BannerAdState, bool>((ref) {
  return BannerAdState();
});
