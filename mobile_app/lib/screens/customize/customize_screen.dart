import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/favorites_provider.dart';
import '../../core/models/models.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  double _sugarLevel = 0.5;
  int _selectedMilk = 0;
  List<bool> _toppings = [];

  ProductModel? _product;
  bool _isLoading = true;
  bool _isInit = false;
  bool _isAdding = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      final productId = ModalRoute.of(context)?.settings.arguments as int?;
      if (productId != null) {
        _loadProduct(productId);
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadProduct(int id) async {
    final prov = context.read<ProductProvider>();
    final product = await prov.loadProductDetail(id);
    if (mounted && product != null) {
      setState(() {
        _product = product;
        _isLoading = false;
        if (product.availableToppings != null) {
          _toppings = List.generate(
            product.availableToppings!.length,
            (_) => false,
          );
        }
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  IconData _getIconForName(String name) {
    if (name.toLowerCase().contains('oat')) return Icons.grass;
    if (name.toLowerCase().contains('almond')) return Icons.spa;
    if (name.toLowerCase().contains('skim')) return Icons.water_drop_outlined;
    if (name.toLowerCase().contains('whip')) return Icons.cloud;
    if (name.toLowerCase().contains('caramel')) return Icons.cookie;
    return Icons.water_drop;
  }

  double get _totalPrice {
    if (_product == null) return 0;
    double base = _product!.price;
    // Milk price
    if (_product!.availableMilks != null &&
        _product!.availableMilks!.isNotEmpty &&
        _selectedMilk < _product!.availableMilks!.length) {
      base += _product!.availableMilks![_selectedMilk].extraPrice;
    }
    // Toppings price
    if (_product!.availableToppings != null) {
      for (int i = 0; i < _product!.availableToppings!.length; i++) {
        if (i < _toppings.length && _toppings[i]) {
          base += _product!.availableToppings![i].price;
        }
      }
    }
    return base;
  }

  Future<void> _addToOrder() async {
    if (_product == null) return;
    setState(() => _isAdding = true);

    List<int> selectedToppingIds = [];
    if (_product!.availableToppings != null) {
      for (int i = 0; i < _product!.availableToppings!.length; i++) {
        if (i < _toppings.length && _toppings[i]) {
          selectedToppingIds.add(_product!.availableToppings![i].id);
        }
      }
    }

    int? selectedMilkId;
    if (_product!.availableMilks != null &&
        _product!.availableMilks!.isNotEmpty) {
      selectedMilkId = _product!.availableMilks![_selectedMilk].id;
    }

    final success = await context.read<CartProvider>().addItem(
      productId: _product!.id,
      milkId: selectedMilkId,
      toppingIds: selectedToppingIds,
      sugarLevel: _sugarLevel,
    );

    if (!mounted) return;
    setState(() => _isAdding = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_product!.name} added to cart!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushNamed(context, '/cart');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add to cart'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(leading: const BackButton()),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBrown),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: Text('Product not found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Customize Your Brew', style: AppTextStyles.appTitle),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<FavoritesProvider>().isFavorite(_product!.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            color: AppColors.primaryBrown,
            onPressed: () {
              context.read<FavoritesProvider>().toggleFavorite(_product!.id);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drink Image
                  Hero(
                    tag: 'product_image_${_product!.id}',
                    child: Container(
                      width: double.infinity,
                      height: 260,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.creamBg,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_product!.image != null &&
                              _product!.image!.startsWith('http'))
                            Image.network(_product!.image!, fit: BoxFit.cover)
                          else if (_product!.image != null)
                            Image.asset(
                              _product!.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          else
                            _buildPlaceholder(),
                          Container(
                            color: AppColors.primaryBrown.withValues(alpha: 0.05),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name & Base Price
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _product!.name,
                            style: AppTextStyles.heading2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBrown,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '\$${_product!.price.toStringAsFixed(2)}',
                            style: AppTextStyles.bodySemiBold.copyWith(
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _product!.description.isNotEmpty
                          ? _product!.description
                          : 'Delicious freshly brewed coffee.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(
                    color: AppColors.divider,
                    indent: 20,
                    endIndent: 20,
                  ),
                  const SizedBox(height: 16),

                  // Sugar Level
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sugar Level',
                          style: AppTextStyles.bodyLargeSemiBold,
                        ),
                        Text(
                          '${(_sugarLevel * 100).round()}%',
                          style: AppTextStyles.bodyLargeSemiBold,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primaryBrown,
                        inactiveTrackColor: AppColors.divider,
                        thumbColor: AppColors.primaryBrown,
                        overlayColor: AppColors.primaryBrown.withValues(
                          alpha: 0.1,
                        ),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _sugarLevel,
                        onChanged: (v) => setState(() => _sugarLevel = v),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('NONE', style: AppTextStyles.labelSmall),
                        Text('SWEET', style: AppTextStyles.labelSmall),
                        Text('EXTRA', style: AppTextStyles.labelSmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Milk Selection
                  if (_product!.availableMilks != null &&
                      _product!.availableMilks!.isNotEmpty) ...[
                    const Divider(
                      color: AppColors.divider,
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Milk Selection',
                        style: AppTextStyles.bodyLargeSemiBold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          _product!.availableMilks!.length,
                          (index) {
                            final milk = _product!.availableMilks![index];
                            final isSelected = _selectedMilk == index;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedMilk = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryBrown
                                        : AppColors.border,
                                    width: isSelected ? 1.5 : 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getIconForName(milk.name),
                                      size: 18,
                                      color: isSelected
                                          ? AppColors.primaryBrown
                                          : AppColors.textGrey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      milk.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: isSelected
                                            ? AppColors.primaryBrown
                                            : AppColors.textDark,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                    if (milk.extraPrice > 0) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '(+\$${milk.extraPrice.toStringAsFixed(2)})',
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                              color: isSelected
                                                  ? AppColors.primaryBrown
                                                  : AppColors.textGrey,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Toppings
                  if (_product!.availableToppings != null &&
                      _product!.availableToppings!.isNotEmpty) ...[
                    const Divider(
                      color: AppColors.divider,
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Extra Toppings',
                        style: AppTextStyles.bodyLargeSemiBold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_product!.availableToppings!.length, (
                      index,
                    ) {
                      final topping = _product!.availableToppings![index];
                      // Safety check in case states drift
                      if (index >= _toppings.length) return const SizedBox();
                      final isSelected = _toppings[index];

                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                          left: 20,
                          right: 20,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getIconForName(topping.name),
                                size: 20,
                                color: AppColors.primaryBrown,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topping.name,
                                    style: AppTextStyles.bodySemiBold,
                                  ),
                                  Text(
                                    '+\$${topping.price.toStringAsFixed(2)}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primaryBrown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(
                                  () => _toppings[index] = !_toppings[index],
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryBrown
                                      : AppColors.cardBackground,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryBrown
                                        : AppColors.border,
                                  ),
                                ),
                                child: Icon(
                                  isSelected ? Icons.check : Icons.add,
                                  size: 18,
                                  color: isSelected
                                      ? AppColors.textWhite
                                      : AppColors.textGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('TOTAL PRICE', style: AppTextStyles.labelSmall),
                      Text(
                        '\$${_totalPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _isAdding
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBrown,
                            ),
                          )
                        : CustomButton(
                            text: 'Add to Order',
                            icon: Icons.shopping_cart,
                            onPressed: _addToOrder,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.coffee, size: 60, color: AppColors.primaryBrown),
    );
  }
}
