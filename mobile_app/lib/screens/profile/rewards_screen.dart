import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_assets.dart';
import '../../core/providers/auth_provider.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final int beans = user?.beansBalance ?? 0;
    final int totalEarned = user?.totalBeansEarned ?? 0;
    final String tier = (user?.membershipTier ?? 'bronze').toLowerCase();

    // Determine progress to next tier
    double progress = 0;
    String nextTier = '';
    int beansNeeded = 0;

    if (tier == 'bronze') {
      nextTier = 'Silver';
      beansNeeded = 500;
      progress = (totalEarned / 500).clamp(0.0, 1.0);
    } else if (tier == 'silver') {
      nextTier = 'Gold';
      beansNeeded = 2000;
      progress = (totalEarned / 2000).clamp(0.0, 1.0);
    } else {
      nextTier = 'Max Level';
      progress = 1.0;
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text('Rewards & Benefits', style: AppTextStyles.appTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status Card
            _buildStatusCard(beans, tier, progress, nextTier, totalEarned, beansNeeded),
            const SizedBox(height: 32),

            Text('Tier Benefits', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            _buildBenefitItem(
              icon: Icons.coffee_outlined,
              tierName: 'Bronze',
              benefit: 'Earn 10 beans for every \$1 spent. Early access to new drinks.',
              isCurrent: tier == 'bronze',
            ),
            _buildBenefitItem(
              icon: Icons.star_border,
              tierName: 'Silver',
              benefit: '1.2x beans multiplier. 5% discount on all seasonal drinks.',
              isCurrent: tier == 'silver',
              isLocked: totalEarned < 500,
            ),
            _buildBenefitItem(
              icon: Icons.workspace_premium_outlined,
              tierName: 'Gold',
              benefit: '1.5x beans multiplier. 10% discount on all orders. Free drink on birthday.',
              isCurrent: tier == 'gold',
              isLocked: totalEarned < 2000,
            ),
            const SizedBox(height: 32),

            Text('How it works', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            _buildHowItWorksStep(
              number: '1',
              title: 'Order',
              description: 'Place an order through the app or at any store.',
            ),
            _buildHowItWorksStep(
              number: '2',
              title: 'Earn Beans',
              description: 'Automatically earn beans for every item you buy.',
            ),
            _buildHowItWorksStep(
              number: '3',
              title: 'Upgrade Tier',
              description: 'Reach milestones to unlock Silver and Gold benefits.',
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(int beans, String tier, double progress, String nextTier, int totalEarned, int beansNeeded) {
    Color tierColor;
    switch (tier) {
      case 'gold':
        tierColor = const Color(0xFFFFD700);
        break;
      case 'silver':
        tierColor = const Color(0xFFC0C0C0);
        break;
      default:
        tierColor = const Color(0xFFCD7F32);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryBrown,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrown.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT BALANCE',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white.withOpacity(0.7),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.stars, color: Color(0xFFFFD700), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '$beans Beans',
                        style: AppTextStyles.heading2.copyWith(color: AppColors.textWhite),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tierColor, width: 1.5),
                ),
                child: Text(
                  tier.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (tier != 'gold') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'To $nextTier',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite),
                ),
                Text(
                  '$totalEarned / $beansNeeded earned',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                minHeight: 8,
              ),
            ),
          ] else
            Text(
              'You have reached the maximum tier!',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite),
            ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String tierName,
    required String benefit,
    bool isCurrent = false,
    bool isLocked = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppColors.primaryBrown : AppColors.divider,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isLocked ? AppColors.scaffoldBg : AppColors.creamBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLocked ? Icons.lock_outline : icon,
              color: isLocked ? AppColors.textLight : AppColors.primaryBrown,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tierName, style: AppTextStyles.bodySemiBold),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrown,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Current',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textWhite, fontSize: 10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  benefit,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isLocked ? AppColors.textLight : AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.creamBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.label.copyWith(color: AppColors.primaryBrown),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySemiBold),
                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
