/// API configuration constants.
class ApiConfig {
  ApiConfig._();

  /// Base URL for the Django backend.
  static const String baseUrl = 'https://aura-brew.onrender.com';
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // static const String baseUrl = 'http://192.168.x.x:8000'; // physical device

  static const String apiPrefix = '/api/v1';

  // Auth
  static const String register = '$apiPrefix/auth/register/';
  static const String login = '$apiPrefix/auth/login/';
  static const String profile = '$apiPrefix/auth/profile/';
  static const String changePin = '$apiPrefix/auth/change-pin/';
  static const String addresses = '$apiPrefix/auth/addresses/';

  // Products
  static const String categories = '$apiPrefix/products/categories/';
  static const String products = '$apiPrefix/products/';
  static const String featuredProducts = '$apiPrefix/products/featured/';
  static const String milkOptions = '$apiPrefix/products/milk-options/';
  static const String toppings = '$apiPrefix/products/toppings/';

  // Cart
  static const String cart = '$apiPrefix/cart/';
  static const String cartItems = '$apiPrefix/cart/items/';
  static const String cartClear = '$apiPrefix/cart/clear/';

  // Orders
  static const String orders = '$apiPrefix/orders/';
  static const String placeOrder = '$apiPrefix/orders/place/';

  // Feedback
  static const String feedback = '$apiPrefix/feedback/';

  // Stores
  static const String stores = '$apiPrefix/stores/';

  // Banners
  static const String banners = '$apiPrefix/banners/';

  static String productDetail(int id) => '$apiPrefix/products/$id/';
  static String cartItem(int id) => '$apiPrefix/cart/items/$id/';
  static String cartItemDelete(int id) => '$apiPrefix/cart/items/$id/delete/';
  static String orderDetail(int id) => '$apiPrefix/orders/$id/';
  static String reorder(int id) => '$apiPrefix/orders/$id/reorder/';
}
