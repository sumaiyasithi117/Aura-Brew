from django.contrib import admin
from .models import Order, OrderItem


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields = ('line_total',)


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'status', 'total', 'beans_earned', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('user__full_name', 'user__phone')
    inlines = [OrderItemInline]
    readonly_fields = ('subtotal', 'service_fee', 'tax', 'total', 'beans_earned')
