// lib/presentation/screens/home/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/ad_service.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    await AdService.instance.showAppOpenAd();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryColor.withOpacity(0.45),
                      blurRadius: 35, spreadRadius: 6),
                ],
              ),
              child: const Icon(Icons.document_scanner_rounded,
                  color: Colors.white, size: 58),
            )
                .animate()
                .scale(duration: 700.ms, curve: Curves.elasticOut)
                .fadeIn(),
            const SizedBox(height: 28),
            const Text('Local OCR',
                style: TextStyle(color: Colors.white, fontSize: 34,
                    fontWeight: FontWeight.bold, letterSpacing: 2))
                .animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 10),
            const Text('Offline · Private · Fast',
                style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 1))
                .animate(delay: 500.ms).fadeIn(),
            const SizedBox(height: 60),
            const SizedBox(
              width: 28, height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
              ),
            ).animate(delay: 700.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
