import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  const AppDrawer({super.key, this.selectedIndex = 0, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Drawer(
      backgroundColor: AppColors.scaffoldBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Avatar
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.accentLight,
                        backgroundImage: (user?.avatar != null && user!.avatar!.startsWith('http'))
                            ? NetworkImage(user.avatar!)
                            : null,
                        child: (user?.avatar == null || !user!.avatar!.startsWith('http'))
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primaryBrown,
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        user?.fullName ?? 'Coffee Lover',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(user?.membershipTier ?? 'bronze').toUpperCase()} Member • ${user?.beansBalance ?? 0} beans',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 16),

                      // Menu Items
                      _DrawerItem(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        isSelected: selectedIndex == 0,
                        onTap: () => onItemTap(0),
                      ),
                      _DrawerItem(
                        icon: Icons.receipt_long_outlined,
                        label: 'My Orders',
                        isSelected: selectedIndex == 1,
                        onTap: () => onItemTap(1),
                      ),
                      _DrawerItem(
                        icon: Icons.stars_outlined,
                        label: 'Loyalty Points',
                        isSelected: selectedIndex == 2,
                        onTap: () => onItemTap(2),
                      ),
                      _DrawerItem(
                        icon: Icons.card_giftcard_outlined,
                        label: 'Rewards',
                        isSelected: selectedIndex == 3,
                        onTap: () => onItemTap(3),
                      ),

                      const SizedBox(height: 24),
                      Text('APPLICATION', style: AppTextStyles.drawerSection),
                      const SizedBox(height: 12),

                      _DrawerItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        isSelected: selectedIndex == 4,
                        onTap: () => onItemTap(4),
                      ),
                      _DrawerItem(
                        icon: Icons.help_outline,
                        label: 'Help Center',
                        isSelected: selectedIndex == 5,
                        onTap: () => onItemTap(5),
                      ),
                      _DrawerItem(
                        icon: Icons.feedback_outlined,
                        label: 'Feedback',
                        isSelected: selectedIndex == 6,
                        onTap: () => onItemTap(6),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Sign Out
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onItemTap(7),
                  icon: const Icon(Icons.logout, size: 20),
                  label: Text('Sign Out', style: AppTextStyles.bodySemiBold),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primaryBrown : AppColors.textGrey,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTextStyles.drawerItem.copyWith(
                color: isSelected ? AppColors.textDark : AppColors.textGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
