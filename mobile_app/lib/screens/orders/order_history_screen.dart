import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/order_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/models/models.dart';

class OrderHistoryScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const OrderHistoryScreen({super.key, this.onBackPressed});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<OrderProvider>().loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.deliveredText;
      case 'picked_up':
        return AppColors.pickedUpText;
      case 'preparing':
        return Colors.orange.shade700;
      case 'ready':
        return Colors.blue.shade700;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textGrey;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.deliveredBg;
      case 'picked_up':
        return AppColors.pickedUpBg;
      case 'preparing':
        return Colors.orange.shade50;
      case 'ready':
        return Colors.blue.shade50;
      case 'cancelled':
        return Colors.red.shade50;
      default:
        return AppColors.accentLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackPressed ?? () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text('Order History', style: AppTextStyles.appTitle),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryBrown,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primaryBrown,
            indicatorWeight: 3,
            labelStyle: AppTextStyles.bodySemiBold,
            unselectedLabelStyle: AppTextStyles.bodyMedium,
            tabs: const [
              Tab(text: 'Recent'),
              Tab(text: 'Past'),
            ],
          ),
          Expanded(
            child: orderProv.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBrown,
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(orderProv.orders),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: AppColors.border,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No past orders',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 68,
                  height: 68,
                  color: AppColors.creamBg,
                  child: Center(
                    child: Text(
                      '#${order.id}',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: AppColors.primaryBrown,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id} • ${order.itemCount ?? 0} items',
                      style: AppTextStyles.bodySemiBold,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBgColor(order.status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.statusDisplay,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _statusColor(order.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${order.total.toStringAsFixed(2)} • ${order.beansEarned} beans',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final orderProv = context.read<OrderProvider>();
                  final success = await orderProv.reorder(order.id);
                  if (!mounted) return;
                  if (success) {
                    context.read<CartProvider>().loadCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Items added to cart!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text('Reorder', style: AppTextStyles.buttonTextSmall),
              ),
            ],
          ),
        );
      },
    );
  }
}
