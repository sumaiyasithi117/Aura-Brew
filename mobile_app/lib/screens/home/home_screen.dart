import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_assets.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/favorites_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/custom_drawer_icon.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;
  const HomeScreen({super.key, this.onMenuPressed, this.onProfilePressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = -1; // -1 = all
  int _currentBanner = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final pp = context.read<ProductProvider>();
      if (pp.categories.isEmpty) pp.loadAll();
      pp.loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Map icon names from backend to Flutter icons
  IconData _categoryIcon(String iconName) {
    switch (iconName) {
      case 'coffee':
        return Icons.coffee;
      case 'emoji_food_beverage':
        return Icons.emoji_food_beverage;
      case 'bakery_dining':
        return Icons.bakery_dining;
      default:
        return Icons.local_cafe;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pp = context.watch<ProductProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const CustomDrawerIcon(),
                        onPressed: widget.onMenuPressed,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Aura Brew',
                        style: AppTextStyles.appTitle.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.onProfilePressed,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (user?.storeDetail != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on, size: 12, color: AppColors.primaryBrown),
                                  const SizedBox(width: 4),
                                  Text(
                                    user!.storeDetail!.name,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primaryBrown,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            Text('Welcome back,', style: AppTextStyles.bodySmall),
                            Text(
                              user?.fullName ?? 'Coffee Lover',
                              style: AppTextStyles.bodyLargeSemiBold,
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.accentLight,
                          backgroundImage: (user?.avatar != null && user!.avatar!.startsWith('http')) 
                              ? NetworkImage(user.avatar!) 
                              : null,
                          child: (user?.avatar == null || !user!.avatar!.startsWith('http'))
                              ? const Icon(Icons.person, size: 20, color: AppColors.primaryBrown)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {}); // Refreshes suffix icon visibility
                    pp.searchProducts(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Find your perfect brew...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.search, color: AppColors.textGrey, size: 22),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              pp.searchProducts('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category Chips (from API or Skeleton)
              SizedBox(
                height: 44,
                child: pp.isLoading && pp.categories.isEmpty
                    ? ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, __) => const CategorySkeleton(),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: pp.categories.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return CategoryChip(
                              label: 'All',
                              icon: Icons.local_cafe,
                              isSelected: _selectedCategory == -1,
                              onTap: () {
                                setState(() => _selectedCategory = -1);
                                pp.loadProducts();
                              },
                            );
                          }
                          final cat = pp.categories[index - 1];
                          return CategoryChip(
                            label: cat.name,
                            icon: _categoryIcon(cat.icon),
                            isSelected: _selectedCategory == index - 1,
                            onTap: () {
                              setState(() => _selectedCategory = index - 1);
                              pp.loadProducts(categoryId: cat.id);
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),

              // Seasonal Banner (from API)
              _buildBanner(pp),
              const SizedBox(height: 28),

              // Popular Drinks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Popular Drinks', style: AppTextStyles.sectionTitle),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'See all',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: AppColors.primaryBrown,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product Grid (from API)
              _buildProductGrid(pp),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(ProductProvider pp) {
    if (pp.isLoading && pp.banners.isEmpty) {
      return const BannerSkeleton();
    }
    if (pp.banners.isNotEmpty) {
      return Column(
        children: [
          CarouselSlider.builder(
            itemCount: pp.banners.length,
            options: CarouselOptions(
              height: 190,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              onPageChanged: (index, reason) {
                setState(() => _currentBanner = index);
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final banner = pp.banners[index];
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 0),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primaryBrown,
                  image: const DecorationImage(
                    image: AssetImage(AppAssets.seasonalBanner),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Color(0x66000000), BlendMode.darken),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        banner.badgeText,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      banner.title,
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.textWhite,
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'Order Now',
                        style: AppTextStyles.bodySemiBold.copyWith(
                          color: AppColors.primaryBrown,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pp.banners.asMap().entries.map((entry) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentBanner == entry.key ? 20.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentBanner == entry.key
                      ? AppColors.primaryBrown
                      : AppColors.primaryBrown.withValues(alpha: 0.2),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildProductGrid(ProductProvider pp) {
    final fp = context.watch<FavoritesProvider>();
    // Use featured products if no category selected, otherwise use category products
    final displayProducts = _selectedCategory == -1 ? pp.featured : pp.products;

    if (pp.isProductsLoading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.65,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => const ProductCardSkeleton(),
      );
    }

    if (displayProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 60, color: AppColors.textGrey.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                pp.searchQuery.isNotEmpty ? 'No products found for "${pp.searchQuery}"' : 'No products available', 
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
          imagePath: product.image ?? AppAssets.vanillaLatte,
          heroTag: 'product_image_${product.id}',
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
    );
  }
}
