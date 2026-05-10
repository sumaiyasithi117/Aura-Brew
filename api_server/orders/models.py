from django.db import models
from django.conf import settings


class Order(models.Model):
    """A completed order."""

    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('preparing', 'Preparing'),
        ('ready', 'Ready'),
        ('picked_up', 'Picked Up'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
    ]

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='orders',
    )
    store = models.ForeignKey(
        'stores.Store',
        on_delete=models.SET_NULL,
        null=True,
        related_name='orders',
    )
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default='pending')
    subtotal = models.DecimalField(max_digits=10, decimal_places=2)
    service_fee = models.DecimalField(max_digits=6, decimal_places=2, default=0.85)
    tax = models.DecimalField(max_digits=6, decimal_places=2, default=0.92)
    total = models.DecimalField(max_digits=10, decimal_places=2)
    beans_earned = models.PositiveIntegerField(default=0)
    payment_method = models.CharField(max_length=50, default='card')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'orders'
        ordering = ['-created_at']

    def __str__(self):
        return f'Order #{self.id} — {self.user.full_name}'


class OrderItem(models.Model):
    """A line item in an order."""

    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey('products.Product', on_delete=models.SET_NULL, null=True)
    product_name = models.CharField(max_length=200)  # Snapshot at order time
    quantity = models.PositiveIntegerField(default=1)
    selected_size = models.ForeignKey(
        'products.ProductSize', on_delete=models.SET_NULL, null=True, blank=True
    )
    selected_milk = models.ForeignKey(
        'products.MilkOption', on_delete=models.SET_NULL, null=True, blank=True
    )
    selected_toppings = models.ManyToManyField('products.Topping', blank=True)
    sugar_level = models.FloatField(default=0.5)
    unit_price = models.DecimalField(max_digits=8, decimal_places=2)
    notes = models.TextField(blank=True)

    class Meta:
        db_table = 'order_items'

    def __str__(self):
        return f'{self.quantity}x {self.product_name}'

    @property
    def line_total(self):
        return self.unit_price * self.quantity
