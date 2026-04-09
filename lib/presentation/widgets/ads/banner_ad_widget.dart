// lib/presentation/widgets/ads/banner_ad_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) _loadAd();
  }

  void _loadAd() {
    if (_isDisposed) return;

    final ad = AdService.instance.createBannerAd();
    if (ad == null) return;

    ad.load().then((_) {
      if (!mounted || _isDisposed) {
        ad.dispose();
        return;
      }
      setState(() {
        _bannerAd = ad;
        _isLoaded = true;
      });
    }).catchError((error) {
      debugPrint('Banner ad load error: $error');
      if (!mounted) return;
      // Retry after delay
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted && !_isDisposed) _loadAd();
      });
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
