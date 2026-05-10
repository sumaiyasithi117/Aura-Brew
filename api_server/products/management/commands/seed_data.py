"""
Seed the database with sample data matching the Flutter app's hardcoded data.
Usage: python manage.py seed_data
"""
from django.core.management.base import BaseCommand
from django.contrib.auth.hashers import make_password

from accounts.models import User
from products.models import Category, Product, MilkOption, Topping, ProductSize
from stores.models import Store
from banners.models import Banner


class Command(BaseCommand):
    help = 'Seed database with sample Aura Brew data'

    def handle(self, *args, **options):
        self.stdout.write('Seeding database...\n')

        # ── Categories ──
        coffee, _ = Category.objects.get_or_create(name='Coffee', defaults={'icon': 'coffee', 'ordering': 1})
        tea, _ = Category.objects.get_or_create(name='Tea', defaults={'icon': 'emoji_food_beverage', 'ordering': 2})
        pastries, _ = Category.objects.get_or_create(name='Pastries', defaults={'icon': 'bakery_dining', 'ordering': 3})
        self.stdout.write(f'  ✓ Categories: {Category.objects.count()}')

        # ── Sizes ──
        regular, _ = ProductSize.objects.get_or_create(name='Regular', defaults={'extra_price': 0})
        large, _ = ProductSize.objects.get_or_create(name='Large', defaults={'extra_price': 1.00})

        # ── Milk Options ──
        whole, _ = MilkOption.objects.get_or_create(name='Whole Milk', defaults={'icon': 'water_drop', 'extra_price': 0})
        oat, _ = MilkOption.objects.get_or_create(name='Oat Milk', defaults={'icon': 'grass', 'extra_price': 0.50})
        almond, _ = MilkOption.objects.get_or_create(name='Almond Milk', defaults={'icon': 'spa', 'extra_price': 0.50})
        skim, _ = MilkOption.objects.get_or_create(name='Skim Milk', defaults={'icon': 'water_drop_outlined', 'extra_price': 0})
        self.stdout.write(f'  ✓ Milk Options: {MilkOption.objects.count()}')

        # ── Toppings ──
        whipped, _ = Topping.objects.get_or_create(name='Extra Whipped Cream', defaults={'price': 0.50, 'icon': 'cloud'})
        caramel, _ = Topping.objects.get_or_create(name='Caramel Drizzle', defaults={'price': 0.30, 'icon': 'cookie'})
        self.stdout.write(f'  ✓ Toppings: {Topping.objects.count()}')

        # ── Coffee Products ──
        coffee_products = [
            {'name': 'Vanilla Latte', 'description': 'Creamy & Sweet', 'price': 4.50, 'is_featured': True},
            {'name': 'Iced Americano', 'description': 'Bold & Refreshing', 'price': 3.75, 'is_featured': True},
            {'name': 'Artisan Latte', 'description': 'Single-origin beans with velvety steamed milk.', 'price': 5.50, 'is_featured': True},
            {'name': 'Oat Milk Latte', 'description': 'Regular • Oat Milk • Extra Hot', 'price': 5.50},
            {'name': 'Cold Brew', 'description': 'Smooth & Bold', 'price': 6.25},
        ]
        for cp in coffee_products:
            prod, created = Product.objects.get_or_create(
                name=cp['name'], category=coffee,
                defaults={'description': cp['description'], 'price': cp['price'], 'is_featured': cp.get('is_featured', False)},
            )
            if created:
                prod.available_sizes.set([regular, large])
                prod.available_milks.set([whole, oat, almond, skim])
                prod.available_toppings.set([whipped, caramel])

        # ── Tea Products ──
        tea_products = [
            {'name': 'Herbal Chamomile', 'description': 'Soothing & Caffeine-free', 'price': 4.50, 'is_featured': True},
            {'name': 'Masala Chai', 'description': 'Spiced & Energizing', 'price': 5.25, 'is_featured': True},
            {'name': 'Royal Earl Grey', 'description': 'Bergamot & Floral', 'price': 4.95},
            {'name': 'Jasmine Green', 'description': 'Light & Aromatic', 'price': 4.75},
        ]
        for tp in tea_products:
            prod, created = Product.objects.get_or_create(
                name=tp['name'], category=tea,
                defaults={'description': tp['description'], 'price': tp['price'], 'is_featured': tp.get('is_featured', False)},
            )
            if created:
                prod.available_sizes.set([regular, large])

        # ── Pastry Products ──
        pastry_products = [
            {'name': 'Butter Croissant', 'description': 'Warmed • Salted Butter', 'price': 4.25},
            {'name': 'Pain au Chocolat', 'description': 'Rich chocolate-filled pastry', 'price': 4.25},
        ]
        for pp in pastry_products:
            Product.objects.get_or_create(
                name=pp['name'], category=pastries,
                defaults={'description': pp['description'], 'price': pp['price']},
            )
        self.stdout.write(f'  ✓ Products: {Product.objects.count()}')

        # ── Stores ──
        Store.objects.get_or_create(
            name='Downtown Roastery',
            defaults={
                'address': '452 Velvet Lane, Suite 100',
                'city': 'San Francisco',
                'state': 'CA',
                'zip_code': '94103',
            },
        )
        self.stdout.write(f'  ✓ Stores: {Store.objects.count()}')

        # ── Banners ──
        Banner.objects.get_or_create(
            title='Freshly Roasted Ethiopian Yirgacheffe',
            defaults={
                'subtitle': 'Premium single-origin coffee from Ethiopia',
                'badge_text': 'SEASONAL SELECTION',
                'display_order': 1,
            },
        )
        Banner.objects.get_or_create(
            title='Ceremonial Matcha',
            defaults={
                'subtitle': 'Rich, earthy, and perfectly whisked',
                'badge_text': 'NEW ARRIVAL',
                'display_order': 2,
            },
        )
        self.stdout.write(f'  ✓ Banners: {Banner.objects.count()}')

        self.stdout.write(self.style.SUCCESS('\n✅ Database seeded successfully!'))
