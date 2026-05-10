from decimal import Decimal
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Order, OrderItem
from .serializers import OrderListSerializer, OrderDetailSerializer
from cart.models import Cart


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def order_list(request):
    """GET /api/v1/orders/ — list user's orders."""
    orders = Order.objects.filter(user=request.user).select_related('store')
    serializer = OrderListSerializer(orders, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def place_order(request):
    """POST /api/v1/orders/place/ — create order from cart."""
    try:
        cart = Cart.objects.prefetch_related(
            'items__product', 'items__selected_toppings',
            'items__selected_milk', 'items__selected_size',
        ).get(user=request.user)
    except Cart.DoesNotExist:
        return Response({'detail': 'Cart is empty.'}, status=status.HTTP_400_BAD_REQUEST)

    cart_items = cart.items.all()
    if not cart_items.exists():
        return Response({'detail': 'Cart is empty.'}, status=status.HTTP_400_BAD_REQUEST)

    subtotal = sum(item.subtotal for item in cart_items)
    service_fee = Decimal('0.85')
    tax = Decimal(str(round(float(subtotal) * 0.08, 2)))
    total = subtotal + service_fee + tax
    beans_earned = int(float(total) * 10)

    store_id = request.data.get('store_id') or request.user.store_id

    order = Order.objects.create(
        user=request.user,
        store_id=store_id,
        subtotal=subtotal,
        service_fee=service_fee,
        tax=tax,
        total=total,
        beans_earned=beans_earned,
        payment_method=request.data.get('payment_method', 'card'),
    )

    for cart_item in cart_items:
        order_item = OrderItem.objects.create(
            order=order,
            product=cart_item.product,
            product_name=cart_item.product.name,
            quantity=cart_item.quantity,
            selected_size=cart_item.selected_size,
            selected_milk=cart_item.selected_milk,
            sugar_level=cart_item.sugar_level,
            unit_price=cart_item.subtotal / cart_item.quantity,
            notes=cart_item.notes,
        )
        order_item.selected_toppings.set(cart_item.selected_toppings.all())

    # Update user beans
    request.user.beans_balance += beans_earned
    request.user.total_beans_earned += beans_earned
    request.user.update_membership_tier()
    request.user.save(update_fields=['beans_balance', 'total_beans_earned'])

    # Clear cart
    cart.items.all().delete()

    serializer = OrderDetailSerializer(order)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def order_detail(request, order_id):
    """GET /api/v1/orders/<id>/ — order detail."""
    try:
        order = Order.objects.prefetch_related(
            'items__selected_toppings', 'items__selected_milk', 'items__selected_size',
        ).get(id=order_id, user=request.user)
    except Order.DoesNotExist:
        return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

    serializer = OrderDetailSerializer(order)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def reorder(request, order_id):
    """POST /api/v1/orders/<id>/reorder/ — add past order items to cart."""
    try:
        order = Order.objects.prefetch_related(
            'items__product', 'items__selected_toppings',
            'items__selected_milk', 'items__selected_size',
        ).get(id=order_id, user=request.user)
    except Order.DoesNotExist:
        return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

    cart, _ = Cart.objects.get_or_create(user=request.user)

    for order_item in order.items.all():
        if not order_item.product:
            continue
        from cart.models import CartItem
        cart_item = CartItem.objects.create(
            cart=cart,
            product=order_item.product,
            quantity=order_item.quantity,
            selected_size=order_item.selected_size,
            selected_milk=order_item.selected_milk,
            sugar_level=order_item.sugar_level,
            notes=order_item.notes,
        )
        cart_item.selected_toppings.set(order_item.selected_toppings.all())

    from cart.serializers import CartSerializer
    return Response(CartSerializer(cart).data, status=status.HTTP_201_CREATED)
