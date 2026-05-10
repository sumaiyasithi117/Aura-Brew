from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.safestring import mark_safe
from .models import User, UserAddress


class UserAddressInline(admin.TabularInline):
    model = UserAddress
    extra = 0
    fields = ('label', 'address_line', 'city', 'is_default')


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('avatar_tag', 'phone', 'full_name', 'email', 'store', 'membership_tier', 'beans_balance', 'is_active')
    list_filter = ('membership_tier', 'is_active')
    search_fields = ('phone', 'full_name', 'email')
    ordering = ('-date_joined',)
    readonly_fields = ('avatar_tag',)
    inlines = [UserAddressInline]

    @admin.display(description='Avatar')
    def avatar_tag(self, obj):
        if obj.avatar:
            return mark_safe(f'<img src="{obj.avatar.url}" width="40" height="40" class="admin-avatar" style="border-radius: 50%; object-fit: cover; border: 1px solid #ddd; box-shadow: 0 2px 4px rgba(0,0,0,0.1);" />')
        return "No Image"

    fieldsets = (
        (None, {'fields': ('phone', 'pin')}),
        ('Personal Info', {'fields': ('avatar_tag', 'avatar', 'full_name', 'email')}),
        ('Membership', {'fields': ('membership_tier', 'beans_balance', 'store')}),
        ('Preferences', {'fields': ('is_order_notifications_enabled', 'is_promo_notifications_enabled', 'is_dark_mode_enabled', 'preferred_language')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Dates', {'fields': ('last_login', 'date_joined')}),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('phone', 'full_name', 'pin', 'is_staff', 'is_active'),
        }),
    )
