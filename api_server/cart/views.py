from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Cart, CartItem
from .serializers import CartSerializer, CartItemSerializer


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def cart_view(request):
    """GET /api/v1/cart/ — get or create the user's cart."""
    cart, _ = Cart.objects.get_or_create(user=request.user)
    serializer = CartSerializer(cart)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_cart_item(request):
    """POST /api/v1/cart/items/ — add item to cart."""
    cart, _ = Cart.objects.get_or_create(user=request.user)
    serializer = CartItemSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    serializer.save(cart=cart)
    return Response(CartSerializer(cart).data, status=status.HTTP_201_CREATED)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_cart_item(request, item_id):
    """PATCH /api/v1/cart/items/<id>/ — update quantity/options."""
    try:
        item = CartItem.objects.get(id=item_id, cart__user=request.user)
    except CartItem.DoesNotExist:
        return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

    serializer = CartItemSerializer(item, data=request.data, partial=True)
    serializer.is_valid(raise_exception=True)
    serializer.save()
    cart = Cart.objects.get(user=request.user)
    return Response(CartSerializer(cart).data)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_cart_item(request, item_id):
    """DELETE /api/v1/cart/items/<id>/ — remove item from cart."""
    try:
        item = CartItem.objects.get(id=item_id, cart__user=request.user)
    except CartItem.DoesNotExist:
        return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

    item.delete()
    cart = Cart.objects.get(user=request.user)
    return Response(CartSerializer(cart).data)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def clear_cart(request):
    """DELETE /api/v1/cart/clear/ — clear all items from cart."""
    try:
        cart = Cart.objects.get(user=request.user)
        cart.items.all().delete()
        return Response(CartSerializer(cart).data)
    except Cart.DoesNotExist:
        return Response({'detail': 'Cart not found.'}, status=status.HTTP_404_NOT_FOUND)
