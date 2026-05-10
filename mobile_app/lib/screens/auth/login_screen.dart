import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _obscurePin = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (phone.isEmpty || pin.isEmpty) {
      _showError('Please enter phone and PIN.');
      return;
    }
    if (pin.length != 4) {
      _showError('PIN must be exactly 4 digits.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(phone: phone, pin: pin);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      _showError(auth.error ?? 'Login failed.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.creamBg,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/login_bg.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Color(0x66000000),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBrown,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.coffee,
                          color: AppColors.textWhite,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome Back',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The perfect brew awaits you',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Phone Number
                Text('Phone Number', style: AppTextStyles.bodySemiBold),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: '01XXXXXXXXX',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                ),
                const SizedBox(height: 20),

                // 4-Digit PIN
                Text('4-Digit PIN', style: AppTextStyles.bodySemiBold),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: '••••',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePin
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  obscureText: _obscurePin,
                  keyboardType: TextInputType.number,
                  controller: _pinController,
                  onSuffixTap: () => setState(() => _obscurePin = !_obscurePin),
                ),
                const SizedBox(height: 28),

                // Login Button
                auth.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBrown,
                        ),
                      )
                    : CustomButton(
                        text: 'Login to Your Account',
                        onPressed: _login,
                      ),
                const SizedBox(height: 24),

                // OR Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: AppTextStyles.labelSmall,
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),
                const SizedBox(height: 20),

                // Social Buttons
                Row(
                  children: [
                    SocialLoginButton(
                      label: 'Google',
                      icon: Icons.g_mobiledata,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 12),
                    SocialLoginButton(
                      label: 'Apple',
                      icon: Icons.apple,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Sign Up Link
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/signup'),
                    child: RichText(
                      text: TextSpan(
                        text: 'New to our café? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textGrey,
                        ),
                        children: [
                          TextSpan(
                            text: 'Create an account',
                            style: AppTextStyles.bodySemiBold.copyWith(
                              color: AppColors.primaryBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
