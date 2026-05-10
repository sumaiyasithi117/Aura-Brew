import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  final String _storageKey = 'favorited_product_ids';
  Set<int> _favoriteIds = {};
  bool _isInit = false;

  Set<int> get favoriteIds => _favoriteIds;
  bool get isInit => _isInit;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? storedIds = prefs.getStringList(_storageKey);
      if (storedIds != null) {
        _favoriteIds = storedIds.map((e) => int.tryParse(e) ?? -1).where((e) => e != -1).toSet();
      }
    } catch (_) {}
    _isInit = true;
    notifyListeners();
  }

  Future<void> toggleFavorite(int productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> stringIds = _favoriteIds.map((e) => e.toString()).toList();
      await prefs.setStringList(_storageKey, stringIds);
    } catch (_) {}
  }

  bool isFavorite(int productId) {
    return _favoriteIds.contains(productId);
  }
}
