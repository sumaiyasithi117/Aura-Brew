import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/models/models.dart';
import '../../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  File? _selectedImage;
  int? _selectedStoreId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.fullName);
    _emailCtrl = TextEditingController(text: user?.email);
    _selectedStoreId = user?.storeId;
    
    // Ensure stores are loaded
    final pp = context.read<ProductProvider>();
    if (pp.stores.isEmpty) {
      pp.loadStores();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final success = await context.read<AuthProvider>().updateProfile(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      storeId: _selectedStoreId,
      avatarFile: _selectedImage,
    );
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      final error = context.read<AuthProvider>().error ?? 'Update failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTextStyles.appTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.creamBg,
                      backgroundImage: _selectedImage != null 
                          ? FileImage(_selectedImage!) 
                          : (user?.avatar != null 
                              ? NetworkImage(user!.avatar!) as ImageProvider 
                              : null),
                      child: _selectedImage == null && user?.avatar == null
                          ? const Icon(Icons.person, size: 50, color: AppColors.primaryBrown)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBrown,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: AppColors.textWhite),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                initialValue: user?.phone ?? '',
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Phone Number (Cannot be changed)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: AppColors.scaffoldBg,
                ),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Favorite Store', style: AppTextStyles.bodySemiBold),
              ),
              const SizedBox(height: 8),
              
              Consumer<ProductProvider>(
                builder: (context, pp, child) {
                  if (pp.isLoading && pp.stores.isEmpty) {
                    return const LinearProgressIndicator();
                  }
                  
                  return DropdownButtonFormField<int>(
                    value: pp.stores.any((s) => s.id == _selectedStoreId) ? _selectedStoreId : null,
                    decoration: InputDecoration(
                      hintText: 'Select your preferred branch',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.store_outlined),
                    ),
                    items: pp.stores.map((store) {
                      return DropdownMenuItem<int>(
                        value: store.id,
                        child: Text(store.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedStoreId = val),
                  );
                },
              ),
              const SizedBox(height: 40),
              
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primaryBrown)
                  : CustomButton(
                      text: 'Save Changes',
                      onPressed: _saveProfile,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
