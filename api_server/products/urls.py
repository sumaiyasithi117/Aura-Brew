from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'admin/manage', views.AdminProductViewSet, basename='admin-product')

urlpatterns = [
    path('categories/', views.CategoryListView.as_view(), name='category-list'),
    path('', views.ProductListView.as_view(), name='product-list'),
    path('featured/', views.FeaturedProductListView.as_view(), name='product-featured'),
    path('milk-options/', views.MilkOptionListView.as_view(), name='milk-option-list'),
    path('toppings/', views.ToppingListView.as_view(), name='topping-list'),
    path('<int:pk>/', views.ProductDetailView.as_view(), name='product-detail'),
    path('', include(router.urls)),
]
