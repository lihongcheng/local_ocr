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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            color: AppTheme.darkSurface,
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.history_rounded,
                  label: l.tabHistory,
                  isSelected: index == 0,
                  onTap: () => provider.setNavIndex(0),
                ),
                const SizedBox(width: 80), // FAB占位
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: l.tabSettings,
                  isSelected: index == 1,
                  onTap: () => provider.setNavIndex(1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label,
      required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.primaryColor : Colors.white38;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ]),
      ),
    );
  }
}
