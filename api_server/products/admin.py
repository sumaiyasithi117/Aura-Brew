from django.contrib import admin
from .models import Category, Product, MilkOption, Topping, ProductSize


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'ordering', 'is_active')
    list_editable = ('ordering', 'is_active')


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'price', 'is_featured', 'is_available')
    list_filter = ('category', 'is_featured', 'is_available')
    search_fields = ('name', 'description')
    filter_horizontal = ('available_sizes', 'available_milks', 'available_toppings')


@admin.register(MilkOption)
class MilkOptionAdmin(admin.ModelAdmin):
    list_display = ('name', 'extra_price', 'is_active')


@admin.register(Topping)
class ToppingAdmin(admin.ModelAdmin):
    list_display = ('name', 'price', 'is_active')


@admin.register(ProductSize)
class ProductSizeAdmin(admin.ModelAdmin):
    list_display = ('name', 'extra_price')
