// lib/core/constants/ad_constants.dart

/// 广告开关配置
/// 将 [useTestAds] 设置为 true 使用测试广告，false 使用真实广告
class AdConfig {
  AdConfig._();

  /// ⚠️ 发布前请将此值改为 false
  static const bool useTestAds = false;

  // ============================================================
  // 应用 ID
  // ============================================================
  static const String appId = 'ca-app-pub-6243890571514259~5665210089';

  // ============================================================
  // 真实广告 ID
  // ============================================================
  static const String _realBannerId = 'ca-app-pub-6243890571514259/7862960604';
  static const String _realInterstitialId =
      'ca-app-pub-6243890571514259/6927883968';
  static const String _realRewardedId =
      'ca-app-pub-6243890571514259/2988638951';
  static const String _realAppOpenId = 'ca-app-pub-6243890571514259/8155642057';

  // ============================================================
  // Google 官方测试广告 ID（Android）
  // ============================================================
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testAppOpenId = 'ca-app-pub-3940256099942544/9257395921';

  // ============================================================
  // 动态获取（根据开关自动切换）
  // ============================================================
  static String get bannerId => useTestAds ? _testBannerId : _realBannerId;

  static String get interstitialId =>
      useTestAds ? _testInterstitialId : _realInterstitialId;

  static String get rewardedId =>
      useTestAds ? _testRewardedId : _realRewardedId;

  static String get appOpenId => useTestAds ? _testAppOpenId : _realAppOpenId;
}
