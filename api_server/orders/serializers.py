from rest_framework import serializers
from .models import Order, OrderItem
from products.serializers import MilkOptionSerializer, ToppingSerializer, ProductSizeSerializer


class OrderItemSerializer(serializers.ModelSerializer):
    selected_milk_detail = MilkOptionSerializer(source='selected_milk', read_only=True)
    selected_size_detail = ProductSizeSerializer(source='selected_size', read_only=True)
    selected_toppings_detail = ToppingSerializer(
        source='selected_toppings', many=True, read_only=True
    )
    line_total = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = OrderItem
        fields = [
            'id', 'product', 'product_name', 'quantity',
            'selected_size', 'selected_size_detail',
            'selected_milk', 'selected_milk_detail',
            'selected_toppings', 'selected_toppings_detail',
            'sugar_level', 'unit_price', 'notes', 'line_total',
        ]


class OrderListSerializer(serializers.ModelSerializer):
    """Lightweight order serializer for list views."""

    item_count = serializers.IntegerField(source='items.count', read_only=True)
    store_name = serializers.CharField(source='store.name', read_only=True, default=None)

    class Meta:
        model = Order
        fields = [
            'id', 'status', 'total', 'item_count',
            'store_name', 'beans_earned', 'created_at',
        ]


class OrderDetailSerializer(serializers.ModelSerializer):
    """Full order with items."""

    items = OrderItemSerializer(many=True, read_only=True)
    store_name = serializers.CharField(source='store.name', read_only=True, default=None)

    class Meta:
        model = Order
        fields = [
            'id', 'status', 'subtotal', 'service_fee', 'tax', 'total',
            'beans_earned', 'payment_method', 'store_name',
            'items', 'created_at', 'updated_at',
        ]
