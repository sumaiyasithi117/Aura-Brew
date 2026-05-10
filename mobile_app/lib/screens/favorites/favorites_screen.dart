import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_assets.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/favorites_provider.dart';
import '../../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProductProvider>();
    final fp = context.watch<FavoritesProvider>();

    // Filter products that are marked as favorite
    final favoriteProducts = pp.products.where((p) => fp.isFavorite(p.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text('Your Favorites', style: AppTextStyles.appTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.accentLight,
              child: const Icon(
                Icons.person,
                size: 18,
                color: AppColors.primaryBrown,
              ),
            ),
          ),
        ],
      ),
      body: !fp.isInit
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBrown),
            )
          : favoriteProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text('No favorites yet', style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the heart icon to save your favorite brews!',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${favoriteProducts.length} items saved', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: favoriteProducts.length,
                        itemBuilder: (context, index) {
                          final product = favoriteProducts[index];
                          return ProductCard(
                            name: product.name,
                            description: product.description,
                            price: '\$${product.price.toStringAsFixed(2)}',
                            imagePath: product.image ?? AppAssets.vanillaLatte,
                            heroTag: 'favorite_image_${product.id}',
                            isFavorite: fp.isFavorite(product.id),
                            isNetworkImage:
                                product.image != null && product.image!.startsWith('http'),
                            onTap: () {
                              Navigator.pushNamed(context, '/customize', arguments: product.id);
                            },
                            onAddTap: () {
                              final cartProvider = context.read<CartProvider>();
                              cartProvider.addItem(productId: product.id);
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
    );
  }
}
