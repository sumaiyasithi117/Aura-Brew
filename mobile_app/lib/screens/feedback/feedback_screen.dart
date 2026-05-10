import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/order_provider.dart';
import '../../core/models/models.dart';
import '../../widgets/custom_button.dart';

class FeedbackScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const FeedbackScreen({super.key, this.onBackPressed});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _serviceRating = 4;
  double _tasteSlider = 0.75;
  final _suggestionsController = TextEditingController();

  String get _tasteLabel {
    if (_tasteSlider <= 0.25) return 'Needs Improvement';
    if (_tasteSlider <= 0.5) return 'Good';
    if (_tasteSlider <= 0.75) return 'Very Good';
    return 'Excellent';
  }

  @override
  void dispose() {
    _suggestionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackPressed ?? () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text('Your Feedback', style: AppTextStyles.appTitle),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Divider(color: AppColors.divider),
            const SizedBox(height: 24),

            // Coffee Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.coffee,
                size: 36,
                color: AppColors.primaryBrown,
              ),
            ),
            const SizedBox(height: 20),

            Text('How was your brew?', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(
              'Order #4829 from Downtown Branch',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 28),

            // Service Quality
            Text('SERVICE QUALITY', style: AppTextStyles.label),
            const SizedBox(height: 14),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _serviceRating = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      index < _serviceRating ? Icons.star : Icons.star_border,
                      size: 40,
                      color: index < _serviceRating
                          ? AppColors.starFilled
                          : AppColors.starEmpty,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),

            // Tags
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTag(Icons.access_time, 'Fast Service'),
                const SizedBox(width: 12),
                _buildTag(Icons.sentiment_satisfied_alt, 'Friendly Barista'),
              ],
            ),
            const SizedBox(height: 32),

            // Taste Satisfaction
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TASTE SATISFACTION', style: AppTextStyles.label),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          _tasteLabel,
                          style: AppTextStyles.bodySemiBold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primaryBrown,
                      inactiveTrackColor: AppColors.divider,
                      thumbColor: AppColors.primaryBrown,
                      overlayColor: AppColors.primaryBrown.withValues(
                        alpha: 0.1,
                      ),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _tasteSlider,
                      onChanged: (v) => setState(() => _tasteSlider = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NEEDS IMPROVEMENT',
                        style: AppTextStyles.labelSmall,
                      ),
                      Text(
                        'PERFECTLY ROASTED',
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Suggestions
            Align(
              alignment: Alignment.centerLeft,
              child: Text('ANY SUGGESTIONS?', style: AppTextStyles.label),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _suggestionsController,
                maxLines: 4,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Tell us what you loved or how we can improve...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            CustomButton(
              text: 'Submit Feedback',
              icon: Icons.send,
              onPressed: () async {
                final feedback = FeedbackModel(
                  serviceRating: _serviceRating,
                  tasteSatisfaction: (_tasteSlider * 100).toInt(),
                  tags: ['Fast Service', 'Friendly Barista'],
                  suggestions: _suggestionsController.text.trim(),
                );
                final success = await context
                    .read<OrderProvider>()
                    .submitFeedback(feedback);
                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for your feedback! ☕'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to submit. Please try again.'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            // Community info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: Row(
                children: [
                  // Avatar stack
                  SizedBox(
                    width: 64,
                    height: 32,
                    child: Stack(
                      children: List.generate(3, (i) {
                        return Positioned(
                          left: i * 18.0,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.accentLight,
                            child: Icon(
                              Icons.person,
                              size: 14,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+85',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Join 2,400+ coffee lovers who shared their thoughts this week.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textGrey),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
