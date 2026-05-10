import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/models.dart';

class CartProvider extends ChangeNotifier {
  CartModel? _cart;
  bool _isLoading = false;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  int get itemCount => _cart?.itemCount ?? 0;
  double get total => _cart?.total ?? 0;

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiClient.get(ApiConfig.cart);
      _cart = CartModel.fromJson(data);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addItem({
    required int productId,
    int quantity = 1,
    int? sizeId,
    int? milkId,
    List<int>? toppingIds,
    double sugarLevel = 0.5,
    String notes = '',
  }) async {
    try {
      final body = <String, dynamic>{
        'product': productId,
        'quantity': quantity,
        'sugar_level': sugarLevel,
        if (sizeId != null) 'selected_size': sizeId,
        if (milkId != null) 'selected_milk': milkId,
        if (toppingIds != null) 'selected_toppings': toppingIds,
        if (notes.isNotEmpty) 'notes': notes,
      };
      final data = await ApiClient.post(ApiConfig.cartItems, body: body);
      _cart = CartModel.fromJson(data);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateItem(int itemId, {int? quantity}) async {
    try {
      final body = <String, dynamic>{};
      if (quantity != null) body['quantity'] = quantity;
      final data = await ApiClient.patch(
        ApiConfig.cartItem(itemId),
        body: body,
      );
      _cart = CartModel.fromJson(data);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> removeItem(int itemId) async {
    try {
      final data = await ApiClient.delete(ApiConfig.cartItemDelete(itemId));
      _cart = CartModel.fromJson(data);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> clearCart() async {
    try {
      final data = await ApiClient.delete(ApiConfig.cartClear);
      _cart = CartModel.fromJson(data);
      notifyListeners();
    } catch (_) {}
  }

  void clearLocalCart() {
    _cart = CartModel(id: _cart?.id ?? 0, items: [], total: 0, itemCount: 0);
    notifyListeners();
  }
}
