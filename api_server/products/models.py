from django.db import models


class Category(models.Model):
    """Product category (Coffee, Tea, Pastries, etc.)."""

    name = models.CharField(max_length=100, unique=True)
    icon = models.CharField(max_length=50, blank=True, help_text='Icon identifier for Flutter')
    ordering = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'categories'
        ordering = ['ordering']
        verbose_name_plural = 'Categories'

    def __str__(self):
        return self.name


class MilkOption(models.Model):
    """Milk options for drink customization."""

    name = models.CharField(max_length=100)
    icon = models.CharField(max_length=50, blank=True)
    extra_price = models.DecimalField(max_digits=6, decimal_places=2, default=0)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'milk_options'
        ordering = ['name']

    def __str__(self):
        return self.name


class Topping(models.Model):
    """Extra toppings for drinks."""

    name = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=6, decimal_places=2)
    icon = models.CharField(max_length=50, blank=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'toppings'
        ordering = ['name']

    def __str__(self):
        return f'{self.name} (+${self.price})'


class ProductSize(models.Model):
    """Product size options."""

    name = models.CharField(max_length=50)  # Regular, Large
    extra_price = models.DecimalField(max_digits=6, decimal_places=2, default=0)

    class Meta:
        db_table = 'product_sizes'
        ordering = ['extra_price']

    def __str__(self):
        return self.name


class Product(models.Model):
    """A menu product (coffee, tea, pastry, etc.)."""

    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    price = models.DecimalField(max_digits=8, decimal_places=2)
    image = models.ImageField(upload_to='products/', blank=True, null=True)
    category = models.ForeignKey(
        Category,
        on_delete=models.CASCADE,
        related_name='products',
    )
    is_featured = models.BooleanField(default=False)
    is_available = models.BooleanField(default=True)
    available_sizes = models.ManyToManyField(ProductSize, blank=True, related_name='products')
    available_milks = models.ManyToManyField(MilkOption, blank=True, related_name='products')
    available_toppings = models.ManyToManyField(Topping, blank=True, related_name='products')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'products'
        ordering = ['-is_featured', 'name']

    def __str__(self):
        return f'{self.name} (${self.price})'
