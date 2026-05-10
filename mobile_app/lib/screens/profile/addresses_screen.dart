import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/models.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AuthProvider>().loadAddresses());
  }

  void _showAddAddressSheet(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final addressController = TextEditingController();
    final cityController = TextEditingController(text: 'Dhaka');
    String selectedLabel = 'home';
    bool isDefault = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Add New Address', style: AppTextStyles.heading3),
              const SizedBox(height: 24),
              
              // Label Selection
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildLabelChip('Home', 'home', selectedLabel, (val) {
                      setModalState(() => selectedLabel = val);
                    }),
                    const SizedBox(width: 8),
                    _buildLabelChip('Work', 'work', selectedLabel, (val) {
                      setModalState(() => selectedLabel = val);
                    }),
                    const SizedBox(width: 8),
                    _buildLabelChip('Other', 'other', selectedLabel, (val) {
                      setModalState(() => selectedLabel = val);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Address Line',
                  hintText: 'e.g. House 12, Road 5, Block B',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrown, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Set as default address'),
                value: isDefault,
                activeColor: AppColors.primaryBrown,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setModalState(() => isDefault = val),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (addressController.text.isEmpty) return;
                    final success = await auth.addAddress(
                      label: selectedLabel,
                      addressLine: addressController.text,
                      city: cityController.text,
                      isDefault: isDefault,
                    );
                    if (context.mounted && success) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Save Address', style: AppTextStyles.buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelChip(String title, String value, String current, Function(String) onSelected) {
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(title),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) onSelected(value);
      },
      selectedColor: AppColors.primaryBrown,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.primaryBrown),
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text('My Addresses', style: AppTextStyles.appTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: auth.isLoading && auth.addresses.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBrown))
          : auth.addresses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: auth.addresses.length,
                  itemBuilder: (context, index) {
                    final address = auth.addresses[index];
                    return _buildAddressCard(address, auth);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressSheet(context),
        backgroundColor: AppColors.primaryBrown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: AppColors.textGrey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No Addresses Saved', style: AppTextStyles.heading3.copyWith(color: AppColors.textGrey)),
          const SizedBox(height: 8),
          Text('Add your home or work address for\nfaster checkout.', 
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address, AuthProvider auth) {
    IconData getIcon() {
      switch (address.label.toLowerCase()) {
        case 'home': return Icons.home_outlined;
        case 'work': return Icons.work_outline;
        default: return Icons.location_on_outlined;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: address.isDefault ? Border.all(color: AppColors.primaryBrown, width: 1.5) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: address.isDefault ? AppColors.primaryBrown : AppColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                getIcon(),
                color: address.isDefault ? Colors.white : AppColors.primaryBrown,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label.toUpperCase(),
                        style: AppTextStyles.label.copyWith(fontSize: 10),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBrown.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('DEFAULT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primaryBrown)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(address.addressLine, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  Text(address.city, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textGrey, size: 20),
              onSelected: (val) {
                if (val == 'delete') {
                  auth.deleteAddress(address.id);
                } else if (val == 'default') {
                  auth.setAddressDefault(address.id);
                }
              },
              itemBuilder: (context) => [
                if (!address.isDefault)
                  const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
