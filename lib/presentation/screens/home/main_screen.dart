// lib/presentation/screens/home/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_ocr/l10n/app_localizations.dart';
import '../../../services/app_provider.dart';
import '../history/history_screen.dart';
import '../scanner/scanner_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../../widgets/common/scan_fab.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _screens = [
    HistoryScreen(),
    ScannerScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final index = provider.currentNavIndex;

    return Scaffold(
      body: IndexedStack(index: index, children: _screens),
      floatingActionButton: index == 0 ? ScanFab(l: l) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          BottomNavigationBar(
            currentIndex: index,
            onTap: provider.setNavIndex,
            items: [
              BottomNavigationBarItem(
                  icon: const Icon(Icons.history_rounded), label: l.tabHistory),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.document_scanner_rounded), label: l.tabScanner),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.settings_rounded), label: l.tabSettings),
            ],
          ),
        ],
      ),
    );
  }
}
