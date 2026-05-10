import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.coffee,
      title: 'Your Perfect Brew,\nYour Way.',
      subtitle:
          'Customize every detail of your favorite coffee or tea with our advanced sliders and options.',
    ),
    _OnboardingData(
      icon: Icons.star,
      title: 'Earn Rewards\nWith Every Sip.',
      subtitle:
          'Collect beans with every purchase and redeem them for free drinks and exclusive merchandise.',
    ),
    _OnboardingData(
      icon: Icons.location_on,
      title: 'Find Your\nNearest Aura.',
      subtitle:
          'Discover Aura Brew locations near you with real-time availability and wait times.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          // Top Image Area
          Expanded(
            flex: 5,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Column(
                  children: [
                    // Image placeholder
                    Expanded(
                      flex: 5,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.creamBg,
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/get_started_bg.png',
                            ),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Color(0x33000000),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            page.icon,
                            size: 80,
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                    // Text content
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              page.title,
                              style: AppTextStyles.heading1,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              page.subtitle,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textGrey,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primaryBrown
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Get Started Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: CustomButton(
              text: 'Get Started',
              icon: Icons.arrow_forward,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
          const SizedBox(height: 16),

          // Sign In Link
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/login');
            },
            child: RichText(
              text: TextSpan(
                text: 'Already have an account? ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textGrey,
                ),
                children: [
                  TextSpan(
                    text: 'Sign In',
                    style: AppTextStyles.bodySemiBold.copyWith(
                      color: AppColors.primaryBrown,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;

  _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
