from django.db import models
from django.conf import settings


class Cart(models.Model):
    """One active cart per user."""

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='cart',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'carts'

    def __str__(self):
        return f'Cart — {self.user.full_name}'

    @property
    def total(self):
        return sum(item.subtotal for item in self.items.all())

    @property
    def item_count(self):
        return sum(item.quantity for item in self.items.all())


class CartItem(models.Model):
    """An item in the cart with customization options."""

    cart = models.ForeignKey(Cart, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey('products.Product', on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    selected_size = models.ForeignKey(
        'products.ProductSize', on_delete=models.SET_NULL, null=True, blank=True
    )
    selected_milk = models.ForeignKey(
        'products.MilkOption', on_delete=models.SET_NULL, null=True, blank=True
    )
    selected_toppings = models.ManyToManyField('products.Topping', blank=True)
    sugar_level = models.FloatField(default=0.5, help_text='0.0 to 1.0')
    notes = models.TextField(blank=True)

    class Meta:
        db_table = 'cart_items'

    def __str__(self):
        return f'{self.quantity}x {self.product.name}'

    @property
    def subtotal(self):
        base = self.product.price
        if self.selected_size:
            base += self.selected_size.extra_price
        if self.selected_milk:
            base += self.selected_milk.extra_price
        for topping in self.selected_toppings.all():
            base += topping.price
        return base * self.quantity
