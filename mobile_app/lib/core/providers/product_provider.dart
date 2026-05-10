import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/models.dart';

class ProductProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<ProductModel> _featured = [];
  List<BannerModel> _banners = [];
  List<MilkOptionModel> _milkOptions = [];
  List<ToppingModel> _toppings = [];
  List<StoreModel> _stores = [];
  bool _isLoading = false;
  bool _isProductsLoading = false;
  String _searchQuery = '';
  List<ProductModel> _searchResults = [];

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _searchQuery.isEmpty ? _products : _searchResults;
  List<ProductModel> get featured => _searchQuery.isEmpty ? _featured : _searchResults;
  List<BannerModel> get banners => _banners;
  List<MilkOptionModel> get milkOptions => _milkOptions;
  List<ToppingModel> get toppings => _toppings;
  List<StoreModel> get stores => _stores;
  bool get isLoading => _isLoading;
  bool get isProductsLoading => _isProductsLoading;
  String get searchQuery => _searchQuery;

  /// Load all initial data.
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        loadCategories(),
        loadFeatured(),
        loadBanners(),
        loadMilkOptions(),
        loadToppings(),
        loadStores(),
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      final data = await ApiClient.get(ApiConfig.categories, auth: false);
      _categories = (data as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadProducts({int? categoryId}) async {
    _products = []; // Clear current list to show shimmer immediately
    _isProductsLoading = true;
    notifyListeners();
    try {
      String url = ApiConfig.products;
      if (categoryId != null) url += '?category=$categoryId';
      final data = await ApiClient.get(url, auth: false);
      final results = data is Map ? data['results'] ?? data : data;
      _products = (results as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } catch (_) {
    } finally {
      _isProductsLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = _products.where((p) {
        final name = p.name.toLowerCase();
        final search = query.toLowerCase();
        return name.contains(search);
      }).toList();
      
      // Also search in featured if needed
      for (var p in _featured) {
        if (p.name.toLowerCase().contains(query.toLowerCase()) && 
            !_searchResults.any((res) => res.id == p.id)) {
          _searchResults.add(p);
        }
      }
    }
    notifyListeners();
  }

  Future<void> loadFeatured() async {
    try {
      final data = await ApiClient.get(ApiConfig.featuredProducts, auth: false);
      _featured = (data as List).map((e) => ProductModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<ProductModel?> loadProductDetail(int id) async {
    try {
      final data = await ApiClient.get(
        ApiConfig.productDetail(id),
        auth: false,
      );
      return ProductModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadBanners() async {
    try {
      final data = await ApiClient.get(ApiConfig.banners, auth: false);
      _banners = (data as List).map((e) => BannerModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadMilkOptions() async {
    try {
      final data = await ApiClient.get(ApiConfig.milkOptions, auth: false);
      _milkOptions = (data as List)
          .map((e) => MilkOptionModel.fromJson(e))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadToppings() async {
    try {
      final data = await ApiClient.get(ApiConfig.toppings, auth: false);
      _toppings = (data as List).map((e) => ToppingModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadStores() async {
    try {
      final data = await ApiClient.get(ApiConfig.stores, auth: false);
      _stores = (data as List).map((e) => StoreModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }
}
