from rest_framework import serializers
from .models import Cart, CartItem
from products.serializers import (
    ProductListSerializer, MilkOptionSerializer,
    ToppingSerializer, ProductSizeSerializer,
)


class CartItemSerializer(serializers.ModelSerializer):
    product_detail = ProductListSerializer(source='product', read_only=True)
    selected_milk_detail = MilkOptionSerializer(source='selected_milk', read_only=True)
    selected_size_detail = ProductSizeSerializer(source='selected_size', read_only=True)
    selected_toppings_detail = ToppingSerializer(
        source='selected_toppings', many=True, read_only=True
    )
    subtotal = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = CartItem
        fields = [
            'id', 'product', 'product_detail', 'quantity',
            'selected_size', 'selected_size_detail',
            'selected_milk', 'selected_milk_detail',
            'selected_toppings', 'selected_toppings_detail',
            'sugar_level', 'notes', 'subtotal',
        ]


class CartSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(many=True, read_only=True)
    total = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    item_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Cart
        fields = ['id', 'items', 'total', 'item_count', 'updated_at']
