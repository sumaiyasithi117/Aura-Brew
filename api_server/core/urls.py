"""
Root URL configuration for Aura Brew backend.
"""

from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

from django.views.static import serve
from django.urls import re_path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/auth/', include('accounts.urls')),
    path('api/v1/products/', include('products.urls')),
    path('api/v1/orders/', include('orders.urls')),
    path('api/v1/cart/', include('cart.urls')),
    path('api/v1/feedback/', include('feedback.urls')),
    path('api/v1/stores/', include('stores.urls')),
    path('api/v1/banners/', include('banners.urls')),
]

# Serve Media Files in both Development and Production (for Render demo)
urlpatterns += [
    re_path(r'^media/(?P<path>.*)$', serve, {'document_root': settings.MEDIA_ROOT}),
    re_path(r'^static/(?P<path>.*)$', serve, {'document_root': settings.STATIC_ROOT}),
]
