import 'package:flutter/material.dart';
import '../../config/constants.dart';

class SideNavRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended; // true = icons + labels (wide desktop)

  const SideNavRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.extended = true,
  });

  @override
  Widget build(BuildContext context) {
    final width = extended ? 240.0 : 80.0;

    return Material(
      elevation: 2,
      color: Colors.white,
      child: Container(
        width: width,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(right: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Brand header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: extended ? 20 : 12,
                  vertical: 20,
                ),
                color: AppColors.primary,
                child: extended
                    ? const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.eco, color: Colors.white, size: 28),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  AppStrings.appName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            AppStrings.appTagline,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    : const Icon(Icons.eco, color: Colors.white, size: 32),
              ),

              const SizedBox(height: 12),

              _NavItem(
                icon: Icons.home_filled,
                label: 'Home',
                selected: currentIndex == 0,
                extended: extended,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.people_alt,
                label: 'People',
                selected: currentIndex == 1,
                extended: extended,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.add_circle,
                label: 'Add Entry',
                selected: currentIndex == 2,
                extended: extended,
                onTap: () => onTap(2),
                highlight: true,
              ),
              _NavItem(
                icon: Icons.history,
                label: 'History',
                selected: currentIndex == 3,
                extended: extended,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.bar_chart,
                label: 'Reports',
                selected: currentIndex == 4,
                extended: extended,
                onTap: () => onTap(4),
              ),

              const Spacer(),

              const Divider(height: 1),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: currentIndex == 5,
                extended: extended,
                onTap: () => onTap(5),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool extended;
  final bool highlight;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.extended,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.primary
        : highlight
            ? AppColors.primary
            : AppColors.textLight;

    final bg = selected
        ? AppColors.primary.withValues(alpha: 0.1)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: extended ? 14 : 0,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: extended
              ? Row(
                  children: [
                    Icon(icon, color: color, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(child: Icon(icon, color: color, size: 24)),
        ),
      ),
    );
  }
}
