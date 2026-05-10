import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.creamBg, AppColors.scaffoldBg],
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.accentLight,
                          backgroundImage: (user?.avatar != null && user!.avatar!.startsWith('http'))
                              ? NetworkImage(user.avatar!)
                              : null,
                          child: (user?.avatar == null || !user!.avatar!.startsWith('http'))
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.primaryBrown,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBrown,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'Coffee Lover',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 8),
                    // Badges
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/rewards'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge(
                            '${(user?.membershipTier ?? 'BRONZE').toUpperCase()} MEMBER',
                          ),
                          const SizedBox(width: 8),
                          _buildBadge('${user?.beansBalance ?? 0} BEANS'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Action Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.history,
                        label: 'REVIEW',
                        title: 'Order History',
                        isHighlighted: false,
                        onTap: () =>
                            Navigator.pushNamed(context, '/order-history'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.card_giftcard,
                        label: 'REWARDS',
                        title: 'My Benefits',
                        isHighlighted: true,
                        onTap: () =>
                            Navigator.pushNamed(context, '/rewards'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Account Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACCOUNT SETTINGS',
                      style: AppTextStyles.drawerSection,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      subtitle: 'Update your name, email and avatar',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      ),
                    ),
                    _buildSettingsItem(
                      icon: Icons.settings_outlined,
                      title: 'App Settings',
                      subtitle: 'Notifications, Theme, Favorite Store, PIN',
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    _buildSettingsItem(
                      icon: Icons.location_on_outlined,
                      title: 'My Addresses',
                      subtitle: 'Manage your delivery locations',
                      onTap: () => Navigator.pushNamed(context, '/addresses'),
                    ),
                    _buildSettingsItem(
                      icon: Icons.credit_card_outlined,
                      title: 'Payment Methods',
                      subtitle: 'Add or remove payment cards',
                      onTap: () => _showComingSoon(context),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'SUPPORT & FEEDBACK',
                      style: AppTextStyles.drawerSection,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      subtitle: 'FAQs and Customer Care',
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildSettingsItem(
                      icon: Icons.chat_bubble_outline,
                      title: 'Feedback',
                      subtitle: 'Rate your experience',
                      onTap: () => Navigator.pushNamed(context, '/feedback'),
                    ),
                    const SizedBox(height: 24),

                    // Sign Out
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await context.read<AuthProvider>().logout();
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (_) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorLight,
                          foregroundColor: AppColors.error,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Sign Out',
                          style: AppTextStyles.buttonText.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // bottom nav space
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primaryBrown,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required String title,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.primaryBrown : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: isHighlighted
              ? null
              : Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? AppColors.white.withValues(alpha: 0.2)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isHighlighted
                    ? AppColors.textWhite
                    : AppColors.primaryBrown,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isHighlighted
                    ? AppColors.textWhite.withValues(alpha: 0.7)
                    : AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodySemiBold.copyWith(
                color: isHighlighted ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.primaryBrown),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodySemiBold),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
