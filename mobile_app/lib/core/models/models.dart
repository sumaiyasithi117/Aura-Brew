import '../utils/url_helper.dart';

class UserModel {
  final int id;
  final String phone;
  final String fullName;
  final String? email;
  final String membershipTier;
  final int beansBalance;
  final String? avatar;
  final String? dateJoined;
  final int totalBeansEarned;
  final bool isOrderNotificationsEnabled;
  final bool isPromoNotificationsEnabled;
  final bool isDarkModeEnabled;
  final String preferredLanguage;
  final int? storeId;
  final StoreModel? storeDetail;

  UserModel({
    required this.id,
    required this.phone,
    required this.fullName,
    this.email,
    this.membershipTier = 'bronze',
    this.beansBalance = 0,
    this.avatar,
    this.dateJoined,
    this.totalBeansEarned = 0,
    this.isOrderNotificationsEnabled = true,
    this.isPromoNotificationsEnabled = false,
    this.isDarkModeEnabled = false,
    this.preferredLanguage = 'English',
    this.storeId,
    this.storeDetail,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'],
      membershipTier: json['membership_tier'] ?? 'bronze',
      beansBalance: json['beans_balance'] ?? 0,
      totalBeansEarned: json['total_beans_earned'] ?? 0,
      isOrderNotificationsEnabled: json['is_order_notifications_enabled'] ?? true,
      isPromoNotificationsEnabled: json['is_promo_notifications_enabled'] ?? false,
      isDarkModeEnabled: json['is_dark_mode_enabled'] ?? false,
      preferredLanguage: json['preferred_language'] ?? 'English',
      avatar: UrlHelper.fixUrl(json['avatar']),
      dateJoined: json['date_joined'],
      storeId: json['store'],
      storeDetail: json['store_details'] != null
          ? StoreModel.fromJson(json['store_details'])
          : null,
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon = '',
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      productCount: json['product_count'] ?? 0,
    );
  }
}

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final int categoryId;
  final String? categoryName;
  final bool isFeatured;
  final bool isAvailable;
  final List<ProductSizeModel>? availableSizes;
  final List<MilkOptionModel>? availableMilks;
  final List<ToppingModel>? availableToppings;

  ProductModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.image,
    required this.categoryId,
    this.categoryName,
    this.isFeatured = false,
    this.isAvailable = true,
    this.availableSizes,
    this.availableMilks,
    this.availableToppings,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      image: UrlHelper.fixUrl(json['image']),
      categoryId: json['category'] ?? 0,
      categoryName: json['category_name'],
      isFeatured: json['is_featured'] ?? false,
      isAvailable: json['is_available'] ?? true,
      availableSizes: json['available_sizes'] != null
          ? (json['available_sizes'] as List)
                .map((e) => ProductSizeModel.fromJson(e))
                .toList()
          : null,
      availableMilks: json['available_milks'] != null
          ? (json['available_milks'] as List)
                .map((e) => MilkOptionModel.fromJson(e))
                .toList()
          : null,
      availableToppings: json['available_toppings'] != null
          ? (json['available_toppings'] as List)
                .map((e) => ToppingModel.fromJson(e))
                .toList()
          : null,
    );
  }
}

class MilkOptionModel {
  final int id;
  final String name;
  final String icon;
  final double extraPrice;

  MilkOptionModel({
    required this.id,
    required this.name,
    this.icon = '',
    this.extraPrice = 0,
  });

  factory MilkOptionModel.fromJson(Map<String, dynamic> json) {
    return MilkOptionModel(
      id: json['id'],
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      extraPrice: double.tryParse(json['extra_price'].toString()) ?? 0,
    );
  }
}

class ToppingModel {
  final int id;
  final String name;
  final double price;
  final String icon;

  ToppingModel({
    required this.id,
    required this.name,
    required this.price,
    this.icon = '',
  });

  factory ToppingModel.fromJson(Map<String, dynamic> json) {
    return ToppingModel(
      id: json['id'],
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      icon: json['icon'] ?? '',
    );
  }
}

class ProductSizeModel {
  final int id;
  final String name;
  final double extraPrice;

  ProductSizeModel({required this.id, required this.name, this.extraPrice = 0});

  factory ProductSizeModel.fromJson(Map<String, dynamic> json) {
    return ProductSizeModel(
      id: json['id'],
      name: json['name'] ?? '',
      extraPrice: double.tryParse(json['extra_price'].toString()) ?? 0,
    );
  }
}

class CartModel {
  final int id;
  final List<CartItemModel> items;
  final double total;
  final int itemCount;

  CartModel({
    required this.id,
    this.items = const [],
    this.total = 0,
    this.itemCount = 0,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'],
      items: json['items'] != null
          ? (json['items'] as List)
                .map((e) => CartItemModel.fromJson(e))
                .toList()
          : [],
      total: double.tryParse(json['total'].toString()) ?? 0,
      itemCount: json['item_count'] ?? 0,
    );
  }
}

class CartItemModel {
  final int id;
  final int productId;
  final ProductModel? productDetail;
  final int quantity;
  final int? selectedSizeId;
  final int? selectedMilkId;
  final MilkOptionModel? selectedMilkDetail;
  final List<int> selectedToppingIds;
  final double sugarLevel;
  final String notes;
  final double subtotal;

  CartItemModel({
    required this.id,
    required this.productId,
    this.productDetail,
    this.quantity = 1,
    this.selectedSizeId,
    this.selectedMilkId,
    this.selectedMilkDetail,
    this.selectedToppingIds = const [],
    this.sugarLevel = 0.5,
    this.notes = '',
    this.subtotal = 0,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      productId: json['product'] ?? 0,
      productDetail: json['product_detail'] != null
          ? ProductModel.fromJson(json['product_detail'])
          : null,
      quantity: json['quantity'] ?? 1,
      selectedSizeId: json['selected_size'],
      selectedMilkId: json['selected_milk'],
      selectedMilkDetail: json['selected_milk_detail'] != null
          ? MilkOptionModel.fromJson(json['selected_milk_detail'])
          : null,
      selectedToppingIds: json['selected_toppings'] != null
          ? List<int>.from(json['selected_toppings'])
          : [],
      sugarLevel: (json['sugar_level'] ?? 0.5).toDouble(),
      notes: json['notes'] ?? '',
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
    );
  }
}

class OrderModel {
  final int id;
  final String status;
  final double? subtotal;
  final double? serviceFee;
  final double? tax;
  final double total;
  final int beansEarned;
  final String? storeName;
  final String? paymentMethod;
  final int? itemCount;
  final List<OrderItemModel>? items;
  final String createdAt;

  OrderModel({
    required this.id,
    this.status = 'pending',
    this.subtotal,
    this.serviceFee,
    this.tax,
    required this.total,
    this.beansEarned = 0,
    this.storeName,
    this.paymentMethod,
    this.itemCount,
    this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      status: json['status'] ?? 'pending',
      subtotal: json['subtotal'] != null
          ? double.tryParse(json['subtotal'].toString())
          : null,
      serviceFee: json['service_fee'] != null
          ? double.tryParse(json['service_fee'].toString())
          : null,
      tax: json['tax'] != null ? double.tryParse(json['tax'].toString()) : null,
      total: double.tryParse(json['total'].toString()) ?? 0,
      beansEarned: json['beans_earned'] ?? 0,
      storeName: json['store_name'],
      paymentMethod: json['payment_method'],
      itemCount: json['item_count'],
      items: json['items'] != null
          ? (json['items'] as List)
                .map((e) => OrderItemModel.fromJson(e))
                .toList()
          : null,
      createdAt: json['created_at'] ?? '',
    );
  }

  String get statusDisplay => status.toUpperCase().replaceAll('_', ' ');
}

class OrderItemModel {
  final int id;
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderItemModel({
    required this.id,
    required this.productName,
    this.quantity = 1,
    required this.unitPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0,
    );
  }
}

class BannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String badgeText;
  final String? image;
  final int? linkProductId;

  BannerModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.badgeText = '',
    this.image,
    this.linkProductId,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      badgeText: json['badge_text'] ?? '',
      image: UrlHelper.fixUrl(json['image']),
      linkProductId: json['link_product'],
    );
  }
}

class StoreModel {
  final int id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String? phone;
  final String? openingTime;
  final String? closingTime;

  StoreModel({
    required this.id,
    required this.name,
    this.address = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.phone,
    this.openingTime,
    this.closingTime,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zip_code'] ?? '',
      phone: json['phone'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
    );
  }

  String get fullAddress => '$address\n$city, $state $zipCode';
}

class FeedbackModel {
  final int? id;
  final int? orderId;
  final int serviceRating;
  final int tasteSatisfaction;
  final List<String> tags;
  final String suggestions;

  FeedbackModel({
    this.id,
    this.orderId,
    required this.serviceRating,
    required this.tasteSatisfaction,
    this.tags = const [],
    this.suggestions = '',
  });

  Map<String, dynamic> toJson() => {
    if (orderId != null) 'order': orderId,
    'service_rating': serviceRating,
    'taste_satisfaction': tasteSatisfaction,
    'tags': tags,
    'suggestions': suggestions,
  };
}

class AddressModel {
  final int id;
  final String label;
  final String addressLine;
  final String city;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.addressLine,
    required this.city,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? 0,
      label: json['label'] ?? 'home',
      addressLine: json['address_line'] ?? '',
      city: json['city'] ?? 'Dhaka',
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'address_line': addressLine,
    'city': city,
    'is_default': isDefault,
  };
}
