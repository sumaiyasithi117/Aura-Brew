from django.urls import path
from . import views

urlpatterns = [
    path('', views.order_list, name='order-list'),
    path('place/', views.place_order, name='order-place'),
    path('<int:order_id>/', views.order_detail, name='order-detail'),
    path('<int:order_id>/reorder/', views.reorder, name='order-reorder'),
]
