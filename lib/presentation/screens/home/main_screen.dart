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
      // FAB 居中悬浮在导航栏正上方
      floatingActionButton: ScanFab(l: l),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _BottomBar(index: index, provider: provider, l: l),
    );
  }
}

/// 底部栏：广告 + 自定义导航（无缺口，无黑色半圆）
class _BottomBar extends StatelessWidget {
  final int index;
  final AppProvider provider;
  final AppLocalizations l;
  const _BottomBar({required this.index, required this.provider, required this.l});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.darkSurface,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 广告位
          const BannerAdWidget(),
          // 分割线
          const Divider(height: 1, thickness: 1, color: AppTheme.darkBorder),
          // 导航行（中间留空给 FAB）
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.history_rounded,
                    label: l.tabHistory,
                    isSelected: index == 0,
                    onTap: () => provider.setNavIndex(0),
                  ),
                ),
                // 中间空位（FAB 浮在其上方）
                const SizedBox(width: 80),
                Expanded(
                  child: _NavItem(
                    icon: Icons.settings_rounded,
                    label: l.tabSettings,
                    isSelected: index == 1,
                    onTap: () => provider.setNavIndex(1),
                  ),
                ),
              ],
            ),
          ),
          // 适配底部安全区
          SizedBox(height: MediaQuery.of(context).padding.bottom),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
