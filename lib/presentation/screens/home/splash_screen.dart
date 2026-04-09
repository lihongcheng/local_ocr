// lib/presentation/screens/home/splash_screen.dart
//
// 启动页：
//   1. 显示动画 logo
//   2. 调用 AppProvider.initOcr() 预热 PP-OCRv5 模型
//      - iOS：立即完成（使用系统 Vision）
//      - Android：首次需下载 ~20MB 模型，显示进度提示
//   3. 展示开屏广告（Android）
//   4. 导航到主页
//
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/ad_service.dart';
import '../../../services/app_provider.dart';
import '../../../services/ocr_service.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusText = '';
  bool _showRetry = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() { _statusText = ''; _showRetry = false; });

    // 最短 splash 时间
    final minDelay = Future.delayed(const Duration(milliseconds: 1400));

    // 预热模型
    final provider = context.read<AppProvider>();
    provider.addListener(_onProviderChange);
    final modelFuture = provider.initOcr();

    await Future.wait([minDelay, modelFuture]);
    provider.removeListener(_onProviderChange);

    if (!mounted) return;

    // Android：模型失败时提示但不阻塞（仍可进入主页，识别时再重试）
    if (Platform.isAndroid && !provider.isModelReady) {
      setState(() {
        _statusText = '⚠️ Model download failed. Check network and retry.';
        _showRetry = true;
      });
      return; // 停在 splash，等用户 retry
    }

    await _navigateToMain();
  }

  void _onProviderChange() {
    if (!mounted) return;
    final status = context.read<AppProvider>().modelStatus;
    switch (status) {
      case ModelStatus.notReady:
        setState(() => _statusText = '');
        break;
      case ModelStatus.downloading:
        setState(() => _statusText = Platform.isAndroid
            ? 'Downloading PP-OCRv5 model (~20 MB)…'
            : 'Preparing OCR engine…');
        break;
      case ModelStatus.ready:
        setState(() => _statusText = 'OCR engine ready ✓');
        break;
      case ModelStatus.error:
        setState(() => _statusText = '');
        break;
    }
  }

  Future<void> _navigateToMain() async {
    // 展示开屏广告（Android）
    await AdService.instance.showAppOpenAd();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 112, height: 112,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryColor.withOpacity(0.5),
                        blurRadius: 40, spreadRadius: 8),
                  ],
                ),
                child: const Icon(Icons.document_scanner_rounded,
                    color: Colors.white, size: 60),
              )
                  .animate()
                  .scale(duration: 700.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 30),

              const Text('Local OCR',
                  style: TextStyle(
                    color: Colors.white, fontSize: 36,
                    fontWeight: FontWeight.bold, letterSpacing: 2,
                  )).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 8),

              Text(
                Platform.isAndroid ? 'Powered by PP-OCRv5' : 'Offline · Private · Fast',
                style: const TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 0.5),
              ).animate(delay: 500.ms).fadeIn(),

              const SizedBox(height: 48),

              // 状态区域
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showRetry
                    ? _buildRetryWidget()
                    : _buildProgressWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 28, height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
          ),
        ).animate(delay: 600.ms).fadeIn(),
        if (_statusText.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _statusText,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(),
        ],
      ],
    );
  }

  Widget _buildRetryWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_rounded, color: Colors.orange, size: 36),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _statusText,
            style: const TextStyle(color: Colors.orange, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _init,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(width: 16),
            // 允许跳过，进入主页（识别时会再次尝试下载）
            TextButton(
              onPressed: _navigateToMain,
              child: const Text('Skip', style: TextStyle(color: Colors.white38)),
            ),
          ],
        ),
      ],
    );
  }
}
