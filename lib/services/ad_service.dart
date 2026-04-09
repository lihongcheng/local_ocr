// lib/services/ad_service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants/ad_constants.dart';
import '../core/constants/app_constants.dart';

class AdService extends ChangeNotifier {
  static AdService? _instance;
  AdService._();
  static AdService get instance {
    _instance ??= AdService._();
    return _instance!;
  }

  // iOS: ads completely disabled
  bool get _adsEnabled => Platform.isAndroid;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;
  int _recognitionCount = 0;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoaded = false;

  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoaded = false;
  bool _isShowingAppOpenAd = false;
  DateTime? _appOpenAdLoadTime;

  Future<void> initialize() async {
    if (!_adsEnabled) {
      debugPrint('ℹ️  AdMob: iOS — ads disabled');
      return;
    }
    await MobileAds.instance.initialize();
    debugPrint(AdConfig.useTestAds
        ? '⚠️  AdMob: TEST ads mode'
        : '✅  AdMob: REAL ads mode');
    _loadInterstitialAd();
    _loadRewardedAd();
    _loadAppOpenAd();
  }

  // ── Interstitial ──────────────────────────────────────────────────────
  void _loadInterstitialAd() {
    if (!_adsEnabled) return;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose(); _interstitialAd = null;
              _isInterstitialLoaded = false;
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose(); _interstitialAd = null;
              _isInterstitialLoaded = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (_) {
          _isInterstitialLoaded = false;
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  void onRecognitionCompleted() {
    if (!_adsEnabled) return;
    _recognitionCount++;
    if (_recognitionCount >= AppConstants.interstitialAdInterval) {
      _recognitionCount = 0;
      showInterstitialAd();
    }
  }

  void showInterstitialAd() {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  // ── Rewarded ──────────────────────────────────────────────────────────
  void _loadRewardedAd() {
    if (!_adsEnabled) return;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          notifyListeners();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose(); _rewardedAd = null;
              _isRewardedLoaded = false;
              notifyListeners();
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose(); _rewardedAd = null;
              _isRewardedLoaded = false;
              notifyListeners();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (_) {
          _isRewardedLoaded = false;
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  bool get isRewardedAdReady => _adsEnabled && _isRewardedLoaded && _rewardedAd != null;

  Future<bool> showRewardedAd({required VoidCallback onRewarded}) async {
    if (!isRewardedAdReady) {
      // iOS or no ad: reward immediately
      onRewarded();
      return true;
    }
    final completer = Completer<bool>();
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded();
        if (!completer.isCompleted) completer.complete(true);
      },
    );
    return completer.future;
  }

  // ── App Open ──────────────────────────────────────────────────────────
  void _loadAppOpenAd() {
    if (!_adsEnabled) return;
    AppOpenAd.load(
      adUnitId: AdConfig.appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdLoaded = true;
          _appOpenAdLoadTime = DateTime.now();
        },
        onAdFailedToLoad: (_) => _isAppOpenAdLoaded = false,
      ),
    );
  }

  bool get _isAppOpenAdValid {
    if (!_isAppOpenAdLoaded || _appOpenAd == null || _appOpenAdLoadTime == null) return false;
    return DateTime.now().difference(_appOpenAdLoadTime!).inHours < 4;
  }

  Future<void> showAppOpenAd() async {
    if (!_adsEnabled || _isShowingAppOpenAd || !_isAppOpenAdValid) {
      _loadAppOpenAd();
      return;
    }
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isShowingAppOpenAd = true,
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAppOpenAd = false;
        ad.dispose(); _appOpenAd = null;
        _isAppOpenAdLoaded = false;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        _isShowingAppOpenAd = false;
        ad.dispose(); _appOpenAd = null;
        _isAppOpenAdLoaded = false;
        _loadAppOpenAd();
      },
    );
    await _appOpenAd!.show();
  }

  // ── Banner ────────────────────────────────────────────────────────────
  BannerAd? createBannerAd() {
    if (!_adsEnabled) return null;
    return BannerAd(
      adUnitId: AdConfig.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {},
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          // Don't dispose immediately - let the caller handle it
        },
      ),
    );
  }
}
