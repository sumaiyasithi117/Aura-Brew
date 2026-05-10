from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.core.validators import RegexValidator


class UserManager(BaseUserManager):
    """Custom manager for phone-based User model."""

    def create_user(self, phone, full_name='', pin='', password=None, **extra_fields):
        if not phone:
            raise ValueError('Phone number is required.')
        user = self.model(phone=phone, full_name=full_name, **extra_fields)
        if pin:
            from django.contrib.auth.hashers import make_password
            user.pin = make_password(pin)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, phone, full_name='Admin', password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        if password is None:
            raise ValueError('Superuser must have a password.')
        return self.create_user(phone, full_name=full_name, password=password, **extra_fields)


class User(AbstractUser):
    """Custom user with 4-digit PIN authentication."""

    MEMBERSHIP_CHOICES = [
        ('bronze', 'Bronze'),
        ('silver', 'Silver'),
        ('gold', 'Gold'),
    ]

    username = None  # Remove username, use phone instead
    phone = models.CharField(
        max_length=15,
        unique=True,
        validators=[RegexValidator(r'^\d{10,15}$', 'Enter a valid phone number.')],
    )
    full_name = models.CharField(max_length=150)
    pin = models.CharField(max_length=128, help_text='Hashed 4-digit PIN')
    membership_tier = models.CharField(
        max_length=10,
        choices=MEMBERSHIP_CHOICES,
        default='bronze',
    )
    beans_balance = models.PositiveIntegerField(default=0)
    total_beans_earned = models.PositiveIntegerField(default=0)
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True)
    store = models.ForeignKey('stores.Store', related_name='favorite_users', on_delete=models.SET_NULL, null=True, blank=True)
    
    # Preferences
    is_order_notifications_enabled = models.BooleanField(default=True)
    is_promo_notifications_enabled = models.BooleanField(default=False)
    is_dark_mode_enabled = models.BooleanField(default=False)
    preferred_language = models.CharField(max_length=20, default='English')


    objects = UserManager()

    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['full_name']

    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'

    def __str__(self):
        return f'{self.full_name} ({self.phone})'

    def update_membership_tier(self):
        """Update membership tier based on total beans earned."""
        if self.total_beans_earned >= 2000:
            self.membership_tier = 'gold'
        elif self.total_beans_earned >= 500:
            self.membership_tier = 'silver'
        else:
            self.membership_tier = 'bronze'
        self.save(update_fields=['membership_tier'])


class UserAddress(models.Model):
    ADDRESS_TYPES = [
        ('home', 'Home'),
        ('work', 'Work'),
        ('other', 'Other'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='addresses')
    label = models.CharField(max_length=20, choices=ADDRESS_TYPES, default='home')
    address_line = models.TextField()
    city = models.CharField(max_length=100, default='Dhaka')
    is_default = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'user_addresses'
        verbose_name = 'User Address'
        verbose_name_plural = 'User Addresses'
        ordering = ['-is_default', '-created_at']

    def save(self, *args, **kwargs):
        if self.is_default:
            # Set all other addresses of this user to not default
            UserAddress.objects.filter(user=self.user).update(is_default=False)
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.label}: {self.address_line}"

