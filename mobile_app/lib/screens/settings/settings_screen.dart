import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/models/models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.appTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: auth.isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBrown))
        : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('NOTIFICATIONS'),
            _buildSwitchTile(
              title: 'Order Updates',
              subtitle: 'Get notified about your order status',
              value: user?.isOrderNotificationsEnabled ?? true,
              onChanged: (v) => auth.updatePreferences(isOrderNotificationsEnabled: v),
            ),
            _buildSwitchTile(
              title: 'Promotions',
              subtitle: 'Special offers and new drink alerts',
              value: user?.isPromoNotificationsEnabled ?? false,
              onChanged: (v) => auth.updatePreferences(isPromoNotificationsEnabled: v),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('APP PREFERENCES'),
            _buildActionTile(
              title: 'Favorite Store',
              subtitle: user?.storeDetail?.name ?? 'Select your preferred branch',
              icon: Icons.store_outlined,
              onTap: () => _showStorePicker(context, auth),
            ),
            _buildSwitchTile(
              title: 'Dark Mode',
              subtitle: 'Switch between light and dark themes',
              value: user?.isDarkModeEnabled ?? false,
              onChanged: (v) => auth.updatePreferences(isDarkModeEnabled: v),
            ),
            _buildActionTile(
              title: 'Language',
              subtitle: user?.preferredLanguage ?? 'English',
              icon: Icons.language,
              onTap: () => _showLanguagePicker(context, auth, user?.preferredLanguage ?? 'English'),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('ACCOUNT SECURITY'),
            _buildActionTile(
              title: 'Change PIN',
              subtitle: 'Update your 4-digit security PIN',
              icon: Icons.lock_outline,
              onTap: () => _showChangePinDialog(context, auth),
            ),
            _buildActionTile(
              title: 'Two-Factor Auth',
              subtitle: 'Disabled',
              icon: Icons.security,
              onTap: () => _showMessage(context, '2FA is coming soon!'),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('LEGAL & SUPPORT'),
            _buildActionTile(
              title: 'Help Center',
              icon: Icons.help_outline,
              onTap: () => _showMessage(context, 'Opening Help Center...'),
            ),
            _buildActionTile(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: () => _showMessage(context, 'Loading Privacy Policy...'),
            ),
            _buildActionTile(
              title: 'Terms of Service',
              icon: Icons.description_outlined,
              onTap: () => _showMessage(context, 'Loading Terms...'),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('DANGER ZONE'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Delete Account',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Permanently remove all your data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.error),
              onTap: () => _showDeleteConfirm(context),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Aura Brew v1.0.0',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showStorePicker(BuildContext context, AuthProvider auth) {
    final stores = context.read<ProductProvider>().stores;
    if (stores.isEmpty) {
      context.read<ProductProvider>().loadStores();
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Favorite Store', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(
                'Your favorite store will be selected by default at checkout.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 24),
              if (stores.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No stores available'),
                ))
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      final isSelected = auth.user?.storeId == store.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accentLight : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryBrown : AppColors.divider,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? AppColors.primaryBrown : AppColors.cardBackground,
                            child: Icon(
                              Icons.storefront,
                              size: 20,
                              color: isSelected ? Colors.white : AppColors.primaryBrown,
                            ),
                          ),
                          title: Text(store.name, style: AppTextStyles.bodySemiBold),
                          subtitle: Text(store.address, style: AppTextStyles.bodySmall),
                          trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: AppColors.primaryBrown)
                            : null,
                          onTap: () async {
                            Navigator.pop(context);
                            if (auth.user != null) {
                              final success = await auth.updateProfile(
                                fullName: auth.user!.fullName,
                                storeId: store.id,
                              );
                              if (context.mounted) {
                                _showMessage(context, success ? 'Favorite store updated!' : 'Failed to update store.');
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showChangePinDialog(BuildContext context, AuthProvider auth) {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change PIN', style: AppTextStyles.heading3),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPinController,
                decoration: const InputDecoration(labelText: 'Current PIN'),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (v) => (v == null || v.length != 4) ? 'Enter 4 digits' : null,
              ),
              TextFormField(
                controller: newPinController,
                decoration: const InputDecoration(labelText: 'New PIN'),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (v) => (v == null || v.length != 4) ? 'Enter 4 digits' : null,
              ),
              TextFormField(
                controller: confirmPinController,
                decoration: const InputDecoration(labelText: 'Confirm New PIN'),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (v) => (v != newPinController.text) ? 'PINs do not match' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBrown),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final success = await auth.changePin(
                  oldPin: oldPinController.text,
                  newPin: newPinController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  _showMessage(context, success ? 'PIN updated successfully!' : (auth.error ?? 'Failed to update PIN'));
                }
              }
            },
            child: const Text('UPDATE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.drawerSection.copyWith(color: AppColors.primaryBrown),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.bodySemiBold),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryBrown,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBrown),
        title: Text(title, style: AppTextStyles.bodySemiBold),
        subtitle: subtitle != null ? Text(subtitle, style: AppTextStyles.bodySmall) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, AuthProvider auth, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Language', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              _langItem(context, auth, 'English', current == 'English'),
              _langItem(context, auth, 'Bengali', current == 'Bengali'),
              _langItem(context, auth, 'Spanish', current == 'Spanish'),
              _langItem(context, auth, 'French', current == 'French'),
            ],
          ),
        );
      },
    );
  }

  Widget _langItem(BuildContext context, AuthProvider auth, String lang, bool isSelected) {
    return ListTile(
      title: Text(lang, style: AppTextStyles.bodyMedium),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primaryBrown) : null,
      onTap: () {
        auth.updatePreferences(preferredLanguage: lang);
        Navigator.pop(context);
      },
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This action cannot be undone. All your beans and history will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessage(context, 'Account deletion requested.');
            },
            child: const Text('DELETE', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}
