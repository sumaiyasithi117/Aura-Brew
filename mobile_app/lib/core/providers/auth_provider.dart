import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  /// Register with phone + 4-digit PIN.
  Future<bool> register({
    required String phone,
    required String fullName,
    required String pin,
    String? email,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final body = {
        'phone': phone,
        'full_name': fullName,
        'pin': pin,
        if (email != null && email.isNotEmpty) 'email': email,
      };
      final data = await ApiClient.post(
        ApiConfig.register,
        body: body,
        auth: false,
      );
      await ApiClient.saveToken(data['token']);
      _user = UserModel.fromJson(data['user']);
      await loadAddresses();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with phone + 4-digit PIN.
  Future<bool> login({required String phone, required String pin}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiClient.post(
        ApiConfig.login,
        body: {'phone': phone, 'pin': pin},
        auth: false,
      );
      await ApiClient.saveToken(data['token']);
      _user = UserModel.fromJson(data['user']);
      await loadAddresses();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load profile from token (auto-login).
  Future<bool> loadProfile() async {
    final hasToken = await ApiClient.isLoggedIn();
    if (!hasToken) return false;
    try {
      final data = await ApiClient.get(ApiConfig.profile);
      _user = UserModel.fromJson(data);
      await loadAddresses(); // Load addresses for global availability
      notifyListeners();
      return true;
    } catch (_) {
      await ApiClient.clearToken();
      return false;
    }
  }

  /// Update Profile with potential avatar upload
  Future<bool> updateProfile({
    required String fullName,
    String? email,
    int? storeId,
    File? avatarFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final fields = {
        'full_name': fullName,
        if (email != null && email.isNotEmpty) 'email': email,
        if (storeId != null) 'store': storeId.toString(),
      };
      
      http.MultipartFile? file;
      if (avatarFile != null) {
        file = await http.MultipartFile.fromPath('avatar', avatarFile.path);
      }

      final data = await ApiClient.patchMultipart(
        ApiConfig.profile,
        fields: fields,
        file: file,
      );
      
      _user = UserModel.fromJson(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update profile. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user preferences (notifications, theme, lang).
  Future<bool> updatePreferences({
    bool? isOrderNotificationsEnabled,
    bool? isPromoNotificationsEnabled,
    bool? isDarkModeEnabled,
    String? preferredLanguage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final body = {
        if (isOrderNotificationsEnabled != null)
          'is_order_notifications_enabled': isOrderNotificationsEnabled,
        if (isPromoNotificationsEnabled != null)
          'is_promo_notifications_enabled': isPromoNotificationsEnabled,
        if (isDarkModeEnabled != null)
          'is_dark_mode_enabled': isDarkModeEnabled,
        if (preferredLanguage != null)
          'preferred_language': preferredLanguage,
      };

      final data = await ApiClient.patch(ApiConfig.profile, body: body);
      _user = UserModel.fromJson(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update preferences. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change user PIN.
  Future<bool> changePin({
    required String oldPin,
    required String newPin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await ApiClient.post(
        ApiConfig.changePin,
        body: {'old_pin': oldPin, 'new_pin': newPin},
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to change PIN. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout.
  Future<void> logout() async {
    await ApiClient.clearToken();
    _user = null;
    _addresses = [];
    notifyListeners();
  }

  // Address Management
  List<AddressModel> _addresses = [];
  List<AddressModel> get addresses => _addresses;

  Future<void> loadAddresses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> data = await ApiClient.get(ApiConfig.addresses);
      _addresses = data.map((json) => AddressModel.fromJson(json)).toList();
    } catch (e) {
      _error = 'Failed to load addresses.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress({
    required String label,
    required String addressLine,
    required String city,
    bool isDefault = false,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final body = {
        'label': label,
        'address_line': addressLine,
        'city': city,
        'is_default': isDefault,
      };
      final data = await ApiClient.post(ApiConfig.addresses, body: body);
      _addresses.insert(0, AddressModel.fromJson(data));
      // If it's default, we might need to reload or manually update others
      if (isDefault) {
        await loadAddresses();
      }
      return true;
    } catch (e) {
      _error = 'Failed to add address.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiClient.delete('${ApiConfig.addresses}$id/');
      _addresses.removeWhere((a) => a.id == id);
      return true;
    } catch (e) {
      _error = 'Failed to delete address.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setAddressDefault(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiClient.patch('${ApiConfig.addresses}$id/', body: {'is_default': true});
      await loadAddresses(); // Refresh list to update all default flags
      return true;
    } catch (e) {
      _error = 'Failed to set default address.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
