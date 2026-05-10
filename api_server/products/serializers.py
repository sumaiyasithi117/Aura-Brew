from rest_framework import serializers
from .models import Category, Product, MilkOption, Topping, ProductSize


class CategorySerializer(serializers.ModelSerializer):
    product_count = serializers.IntegerField(source='products.count', read_only=True)

    class Meta:
        model = Category
        fields = ['id', 'name', 'icon', 'ordering', 'product_count']


class MilkOptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = MilkOption
        fields = ['id', 'name', 'icon', 'extra_price']


class ToppingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Topping
        fields = ['id', 'name', 'price', 'icon']


class ProductSizeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductSize
        fields = ['id', 'name', 'extra_price']


class ProductListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for product lists."""

    category_name = serializers.CharField(source='category.name', read_only=True)

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'price', 'image',
            'category', 'category_name', 'is_featured', 'is_available',
        ]


class ProductDetailSerializer(serializers.ModelSerializer):
    """Full detail serializer with customization options."""

    category_name = serializers.CharField(source='category.name', read_only=True)
    available_sizes = ProductSizeSerializer(many=True, read_only=True)
    available_milks = MilkOptionSerializer(many=True, read_only=True)
    available_toppings = ToppingSerializer(many=True, read_only=True)

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'price', 'image',
            'category', 'category_name', 'is_featured', 'is_available',
            'available_sizes', 'available_milks', 'available_toppings',
            'created_at', 'updated_at',
        ]

class AdminProductSerializer(serializers.ModelSerializer):
    """Serializer for Admin to create/update products with M2M fields."""
    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'price', 'image',
            'category', 'is_featured', 'is_available',
            'available_sizes', 'available_milks', 'available_toppings',
        ]

