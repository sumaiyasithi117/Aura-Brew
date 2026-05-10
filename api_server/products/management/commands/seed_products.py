from django.core.management.base import BaseCommand
from products.models import Category, Product, ProductSize, MilkOption, Topping
from decimal import Decimal

class Command(BaseCommand):
    help = 'Seeds the database with initial coffee shop products'

    def handle(self, *args, **kwargs):
        self.stdout.write('Seeding data...')

        # Categories
        cat_coffee, _ = Category.objects.get_or_create(name='Coffee', defaults={'icon': 'coffee', 'ordering': 1})
        cat_tea, _ = Category.objects.get_or_create(name='Tea', defaults={'icon': 'leaf', 'ordering': 2})
        cat_pastry, _ = Category.objects.get_or_create(name='Pastries', defaults={'icon': 'bread', 'ordering': 3})

        # Product Sizes
        size_reg, _ = ProductSize.objects.get_or_create(name='Regular', defaults={'extra_price': Decimal('0.00')})
        size_lrg, _ = ProductSize.objects.get_or_create(name='Large', defaults={'extra_price': Decimal('1.50')})

        # Milk Options
        milk_whole, _ = MilkOption.objects.get_or_create(name='Whole Milk', defaults={'extra_price': Decimal('0.00')})
        milk_oat, _ = MilkOption.objects.get_or_create(name='Oat Milk', defaults={'extra_price': Decimal('0.75')})
        milk_almond, _ = MilkOption.objects.get_or_create(name='Almond Milk', defaults={'extra_price': Decimal('0.75')})

        # Toppings
        top_vanilla, _ = Topping.objects.get_or_create(name='Vanilla Syrup', defaults={'price': Decimal('0.50')})
        top_caramel, _ = Topping.objects.get_or_create(name='Caramel Drizzle', defaults={'price': Decimal('0.60')})

        # Products
        prod_latte, created = Product.objects.get_or_create(
            name='Caffe Latte',
            category=cat_coffee,
            defaults={
                'description': 'Rich espresso balanced with steamed milk and a light layer of foam.',
                'price': Decimal('4.50'),
                'is_featured': True,
            }
        )
        if created:
            prod_latte.available_sizes.add(size_reg, size_lrg)
            prod_latte.available_milks.add(milk_whole, milk_oat, milk_almond)
            prod_latte.available_toppings.add(top_vanilla, top_caramel)

        prod_matcha, created = Product.objects.get_or_create(
            name='Matcha Green Tea Latte',
            category=cat_tea,
            defaults={
                'description': 'Smooth and creamy matcha sweetened just right and served with steamed milk.',
                'price': Decimal('4.95'),
                'is_featured': True,
            }
        )
        if created:
            prod_matcha.available_sizes.add(size_reg, size_lrg)
            prod_matcha.available_milks.add(milk_whole, milk_oat, milk_almond)

        prod_croissant, created = Product.objects.get_or_create(
            name='Butter Croissant',
            category=cat_pastry,
            defaults={
                'description': 'Flaky, buttery, perfectly baked croissant.',
                'price': Decimal('3.25'),
            }
        )

        self.stdout.write(self.style.SUCCESS('Successfully seeded the database.'))
