import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_assets.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/favorites_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';

class TeaSelectionScreen extends StatefulWidget {
  const TeaSelectionScreen({super.key});

  @override
  State<TeaSelectionScreen> createState() => _TeaSelectionScreenState();
}

class _TeaSelectionScreenState extends State<TeaSelectionScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Herbal', 'Black', 'Green'];

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProductProvider>();
    final fp = context.watch<FavoritesProvider>();
    final displayProducts = pp.products;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Tea Selection', style: AppTextStyles.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            color: AppColors.primaryBrown,
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.textGrey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search your favorite tea...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    const Icon(Icons.tune, color: AppColors.textGrey, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Filter Chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return CategoryChip(
                      label: _filters[index],
                      isSelected: _selectedFilter == index,
                      onTap: () => setState(() => _selectedFilter = index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Featured Banner
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primaryBrown,
                  image: const DecorationImage(
                    image: AssetImage(AppAssets.matchaBanner),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Color(0x66000000),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'NEW ARRIVAL',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ceremonial Matcha',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rich, earthy, and perfectly whisked',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Premium Blends
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Premium Blends', style: AppTextStyles.sectionTitle),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'View All',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: AppColors.primaryBrown,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tea Grid
              displayProducts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          pp.isLoading
                              ? 'Loading teas...'
                              : 'No teas available',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.65,
                          ),
                      itemCount: displayProducts.length,
                      itemBuilder: (context, index) {
                        final product = displayProducts[index];
                        return ProductCard(
                          name: product.name,
                          description: product.description,
                          price: '\$${product.price.toStringAsFixed(2)}',
                          imagePath: product.image ?? AppAssets.herbalChamomile,
                          heroTag: 'product_image_${product.id}',
                          isFavorite: fp.isFavorite(product.id),
                          isNetworkImage:
                              product.image != null &&
                              product.image!.startsWith('http'),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/customize',
                            arguments: product.id,
                          ),
                          onAddTap: () {
                            // Add quickly with default options
                            context.read<CartProvider>().addItem(
                              productId: product.id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          onFavoriteTap: () {
                            fp.toggleFavorite(product.id);
                          },
                        );
                      },
                    ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
