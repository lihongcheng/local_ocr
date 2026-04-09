// lib/presentation/screens/home/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_ocr/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/app_provider.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../../widgets/common/scan_fab.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _screens = [
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final index = provider.currentNavIndex;

    return Scaffold(
      body: IndexedStack(index: index, children: _screens),
      floatingActionButton: ScanFab(l: l),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 广告位在底部导航栏正上方
          const BannerAdWidget(),
          NavigationBar(
            backgroundColor: AppTheme.darkSurface,
            indicatorColor: AppTheme.primaryColor.withOpacity(0.2),
            selectedIndex: index,
            onDestinationSelected: (i) => provider.setNavIndex(i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.history_rounded, color: Colors.white38),
                selectedIcon: Icon(Icons.history_rounded, color: AppTheme.primaryColor),
                label: l.tabHistory,
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_rounded, color: Colors.white38),
                selectedIcon: Icon(Icons.settings_rounded, color: AppTheme.primaryColor),
                label: l.tabSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

