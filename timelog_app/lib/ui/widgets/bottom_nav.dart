import 'package:flutter/material.dart';

import '../../core/theme.dart';

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final AppThemeData theme;

  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        border: Border(top: BorderSide(color: theme.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.timer_outlined,
                activeIcon: Icons.timer,
                label: 'Timer',
                isActive: selectedIndex == 0,
                theme: theme,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.checklist_outlined,
                activeIcon: Icons.checklist,
                label: 'Úkoly',
                isActive: selectedIndex == 1,
                theme: theme,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'History',
                isActive: selectedIndex == 2,
                theme: theme,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'Stats',
                isActive: selectedIndex == 3,
                theme: theme,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                isActive: selectedIndex == 4,
                theme: theme,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final AppThemeData theme;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? theme.accent : theme.faint;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
