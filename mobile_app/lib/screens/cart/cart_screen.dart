import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/models/models.dart';
import '../../widgets/custom_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int? _selectedStoreId;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _selectedStoreId = auth.user?.storeId;
    context.read<CartProvider>().loadCart();
  }

  Future<void> _placeOrder() async {
    final orderProv = context.read<OrderProvider>();
    final cartProv = context.read<CartProvider>();

    final storeId = _selectedStoreId;
    final order = await orderProv.placeOrder(storeId: storeId);

    if (!mounted) return;

    if (order != null) {
      // Clear cart locally first so UI updates immediately
      cartProv.clearLocalCart();
      
      // Navigate to success screen and clear stack
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/order-success', 
        (route) => false,
        arguments: order,
      );

      // Reload cart in background to sync with server
      cartProv.loadCart();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProv = context.watch<CartProvider>();
    final orderProv = context.watch<OrderProvider>();
    final cart = cartProv.cart;
    final items = cart?.items ?? [];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text('Aura Brew', style: AppTextStyles.appTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: cartProv.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBrown),
            )
          : items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: AppColors.divider),
                        const SizedBox(height: 16),
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Selection',
                              style: AppTextStyles.heading3,
                            ),
                            Text(
                              '${cart!.itemCount} Items',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Cart Items (from API)
                        ...items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildCartItem(item, cartProv),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Pickup Location
                        _buildPickupLocation(),
                        const SizedBox(height: 12),

                        // Payment
                        _buildPaymentCard(),
                        const SizedBox(height: 16),

                        // Price Breakdown
                        _buildPriceBreakdown(cart),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Place Order Button
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: CustomButton(
                      text: 'PLACE ORDER',
                      icon: Icons.arrow_forward,
                      isLoading: orderProv.isLoading,
                      onPressed: _placeOrder,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text('Your cart is empty', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Add some delicious drinks!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item, CartProvider cartProv) {
    final product = item.productDetail;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              height: 72,
              color: AppColors.creamBg,
              child: const Icon(
                Icons.coffee,
                color: AppColors.primaryBrown,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product?.name ?? 'Item',
                        style: AppTextStyles.bodySemiBold,
                      ),
                    ),
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySemiBold,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product?.description ?? '',
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildQtyButton(Icons.remove, () {
                      if (item.quantity > 1) {
                        cartProv.updateItem(
                          item.id,
                          quantity: item.quantity - 1,
                        );
                      } else {
                        cartProv.removeItem(item.id);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        '${item.quantity}',
                        style: AppTextStyles.bodySemiBold,
                      ),
                    ),
                    _buildQtyButton(Icons.add, () {
                      cartProv.updateItem(item.id, quantity: item.quantity + 1);
                    }),
                    const Spacer(),
                    // Delete button
                    GestureDetector(
                      onTap: () => cartProv.removeItem(item.id),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primaryBrown,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.textWhite),
      ),
    );
  }

  Widget _buildPickupLocation() {
    final stores = context.read<ProductProvider>().stores;
    final userStore = context.watch<AuthProvider>().user?.storeDetail;
    
    // Find either selected store or user's favorite or first available
    final displayStore = stores.firstWhere(
      (s) => s.id == _selectedStoreId,
      orElse: () => userStore ?? (stores.isNotEmpty ? stores.first : StoreModel(id: 0, name: 'Loading...')),
    );

    return _buildInfoCard(
      icon: Icons.location_on_outlined,
      title: 'PICKUP LOCATION',
      children: [
        Text(
          displayStore.name,
          style: AppTextStyles.bodySemiBold,
        ),
        const SizedBox(height: 4),
        Text(
          displayStore.fullAddress,
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showStorePicker(stores),
          child: Text(
            'CHANGE STORE',
            style: AppTextStyles.label.copyWith(
              decoration: TextDecoration.underline,
              color: AppColors.primaryBrown,
            ),
          ),
        ),
      ],
    );
  }

  void _showStorePicker(List<StoreModel> stores) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Store Branch', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return ListTile(
                      title: Text(store.name, style: AppTextStyles.bodySemiBold),
                      subtitle: Text(store.address, style: AppTextStyles.bodySmall),
                      trailing: _selectedStoreId == store.id
                          ? const Icon(Icons.check_circle, color: AppColors.primaryBrown)
                          : null,
                      onTap: () {
                        setState(() => _selectedStoreId = store.id);
                        Navigator.pop(context);
                      },
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

  Widget _buildPaymentCard() {
    return _buildInfoCard(
      icon: Icons.credit_card,
      title: 'PAYMENT',
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F71),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'VISA',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Visa ending in 4242', style: AppTextStyles.bodySemiBold),
                Text('EXPIRES 12/26', style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(CartModel cart) {
    final estimatedTax = (cart.total * 0.08);
    const serviceFee = 0.85;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', '\$${cart.total.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildPriceRow('Service Fee', '\$${serviceFee.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildPriceRow('Tax', '\$${estimatedTax.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.bodyLargeSemiBold),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${(cart.total + serviceFee + estimatedTax).toStringAsFixed(2)}',
                    style: AppTextStyles.price.copyWith(
                      color: AppColors.primaryBrown,
                    ),
                  ),
                  Text(
                    '${(cart.total * 10).toInt()} BEANS EARNED',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryBrown,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryBrown),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
        ),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
