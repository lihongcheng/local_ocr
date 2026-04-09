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

  // iOS完全禁用广告
  static bool get adsEnabled => Platform.isAndroid;

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
    if (!adsEnabled) {
      debugPrint('ℹ️  AdMob: iOS — ads completely disabled');
      return;
    }
    try {
      await MobileAds.instance.initialize();
      debugPrint(AdConfig.useTestAds
          ? '⚠️  AdMob running in TEST mode'
          : '✅  AdMob running in PRODUCTION mode');
      // 预加载各类广告
      _loadInterstitialAd();
      _loadRewardedAd();
      _loadAppOpenAd();
    } catch (e) {
      debugPrint('AdMob init error: $e');
    }
  }

  // ── 插页广告 ──────────────────────────────────────────────────────────
  void _loadInterstitialAd() {
    if (!adsEnabled) return;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          debugPrint('✅ Interstitial ad loaded');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              _loadInterstitialAd(); // 预加载下一个
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial show failed: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial load failed: $error');
          _isInterstitialLoaded = false;
          // 30秒后重试
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  /// 每次识别完成调用，达到阈值后展示插页广告
  void onRecognitionCompleted() {
    if (!adsEnabled) return;
    _recognitionCount++;
    debugPrint('Recognition count: $_recognitionCount / ${AppConstants.interstitialAdInterval}');
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

  // ── 激励广告 ──────────────────────────────────────────────────────────
  void _loadRewardedAd() {
    if (!adsEnabled) return;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          debugPrint('✅ Rewarded ad loaded');
          notifyListeners();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedLoaded = false;
              notifyListeners();
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Rewarded show failed: $error');
              ad.dispose();
              _rewardedAd = null;
              _isRewardedLoaded = false;
              notifyListeners();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded load failed: $error');
          _isRewardedLoaded = false;
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  bool get isRewardedAdReady => adsEnabled && _isRewardedLoaded && _rewardedAd != null;

  /// 展示激励广告，iOS或无广告时直接触发回调
  Future<bool> showRewardedAd({required VoidCallback onRewarded}) async {
    if (!adsEnabled || !isRewardedAdReady) {
      // iOS直接给奖励，无需看广告
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
    // 超时保护：15秒后如果没完成，认为失败
    Future.delayed(const Duration(seconds: 15), () {
      if (!completer.isCompleted) completer.complete(false);
    });
    return completer.future;
  }

  // ── 开屏广告 ──────────────────────────────────────────────────────────
  void _loadAppOpenAd() {
    if (!adsEnabled) return;
    AppOpenAd.load(
      adUnitId: AdConfig.appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdLoaded = true;
          _appOpenAdLoadTime = DateTime.now();
          debugPrint('✅ App open ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('App open ad load failed: $error');
          _isAppOpenAdLoaded = false;
        },
      ),
    );
  }

  bool get _isAppOpenAdValid {
    if (!_isAppOpenAdLoaded || _appOpenAd == null || _appOpenAdLoadTime == null) return false;
    // 开屏广告4小时内有效
    return DateTime.now().difference(_appOpenAdLoadTime!).inHours < 4;
  }

  Future<void> showAppOpenAd() async {
    if (!adsEnabled || _isShowingAppOpenAd || !_isAppOpenAdValid) {
      if (adsEnabled) _loadAppOpenAd(); // 预加载下一次
      return;
    }
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isShowingAppOpenAd = true,
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenAdLoaded = false;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('App open show failed: $error');
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenAdLoaded = false;
        _loadAppOpenAd();
      },
    );
    await _appOpenAd!.show();
  }

  // ── 横幅广告（由widget管理生命周期）─────────────────────────────────
  BannerAd? createBannerAd() {
    if (!adsEnabled) return null;
    return BannerAd(
      adUnitId: AdConfig.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => debugPrint('✅ Banner ad loaded'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner load failed: $error');
          ad.dispose(); // 必须dispose失败的ad
        },
      ),
    );
  }
}
