from rest_framework import generics
from rest_framework.permissions import AllowAny
from .models import Category, Product, MilkOption, Topping
from .serializers import (
    CategorySerializer,
    ProductListSerializer,
    ProductDetailSerializer,
    MilkOptionSerializer,
    ToppingSerializer,
)


class CategoryListView(generics.ListAPIView):
    """GET /api/v1/products/categories/ — list all categories."""
    queryset = Category.objects.filter(is_active=True)
    serializer_class = CategorySerializer
    permission_classes = [AllowAny]
    pagination_class = None


class ProductListView(generics.ListAPIView):
    """GET /api/v1/products/ — list products, filter by ?category=<id>."""
    serializer_class = ProductListSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        qs = Product.objects.filter(is_available=True).select_related('category')
        category_id = self.request.query_params.get('category')
        if category_id:
            qs = qs.filter(category_id=category_id)
        return qs


class ProductDetailView(generics.RetrieveAPIView):
    """GET /api/v1/products/<id>/ — product detail with options."""
    queryset = Product.objects.prefetch_related(
        'available_sizes', 'available_milks', 'available_toppings'
    )
    serializer_class = ProductDetailSerializer
    permission_classes = [AllowAny]


class FeaturedProductListView(generics.ListAPIView):
    """GET /api/v1/products/featured/ — featured products."""
    queryset = Product.objects.filter(is_featured=True, is_available=True)
    serializer_class = ProductListSerializer
    permission_classes = [AllowAny]
    pagination_class = None


class MilkOptionListView(generics.ListAPIView):
    """GET /api/v1/products/milk-options/ — all milk options."""
    queryset = MilkOption.objects.filter(is_active=True)
    serializer_class = MilkOptionSerializer
    permission_classes = [AllowAny]
    pagination_class = None


class ToppingListView(generics.ListAPIView):
    """GET /api/v1/products/toppings/ — all toppings."""
    queryset = Topping.objects.filter(is_active=True)
    serializer_class = ToppingSerializer
    permission_classes = [AllowAny]
    pagination_class = None

from rest_framework import viewsets
from rest_framework.permissions import IsAdminUser
from .serializers import AdminProductSerializer

class AdminProductViewSet(viewsets.ModelViewSet):
    """Admin CRUD for products."""
    queryset = Product.objects.all()
    serializer_class = AdminProductSerializer
    permission_classes = [IsAdminUser]

