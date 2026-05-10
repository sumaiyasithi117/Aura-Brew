import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/models.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiClient.get(ApiConfig.orders);
      _orders = (data as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<OrderModel?> placeOrder({
    int? storeId,
    String paymentMethod = 'card',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final body = <String, dynamic>{
        'payment_method': paymentMethod,
        if (storeId != null) 'store_id': storeId,
      };
      final data = await ApiClient.post(ApiConfig.placeOrder, body: body);
      final order = OrderModel.fromJson(data);
      _orders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> reorder(int orderId) async {
    try {
      await ApiClient.post(ApiConfig.reorder(orderId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitFeedback(FeedbackModel feedback) async {
    try {
      await ApiClient.post(ApiConfig.feedback, body: feedback.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }
}
