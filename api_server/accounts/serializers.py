from rest_framework import serializers
from django.contrib.auth.hashers import make_password, check_password
from rest_framework.authtoken.models import Token
from .models import User, UserAddress


class RegisterSerializer(serializers.ModelSerializer):
    """Register a new user with phone + 4-digit PIN."""

    pin = serializers.CharField(write_only=True, min_length=4, max_length=4)

    class Meta:
        model = User
        fields = ['phone', 'full_name', 'pin', 'email']
        extra_kwargs = {
            'email': {'required': False},
        }

    def validate_pin(self, value):
        if not value.isdigit() or len(value) != 4:
            raise serializers.ValidationError('PIN must be exactly 4 digits.')
        return value

    def create(self, validated_data):
        raw_pin = validated_data.pop('pin')
        user = User(**validated_data)
        user.pin = make_password(raw_pin)
        user.set_unusable_password()
        user.save()
        return user


class LoginSerializer(serializers.Serializer):
    """Login with phone + 4-digit PIN, returns auth token."""

    phone = serializers.CharField()
    pin = serializers.CharField(min_length=4, max_length=4)

    def validate(self, data):
        phone = data.get('phone')
        pin = data.get('pin')

        try:
            user = User.objects.get(phone=phone)
        except User.DoesNotExist:
            raise serializers.ValidationError('Invalid phone or PIN.')

        if not check_password(pin, user.pin):
            raise serializers.ValidationError('Invalid phone or PIN.')

        if not user.is_active:
            raise serializers.ValidationError('Account is deactivated.')

        data['user'] = user
        return data


from stores.serializers import StoreSerializer

class UserProfileSerializer(serializers.ModelSerializer):
    """Read/update user profile."""
    store_details = StoreSerializer(source='store', read_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'phone', 'full_name', 'email',
            'membership_tier', 'beans_balance', 'total_beans_earned',
            'avatar', 'store', 'store_details',
            'is_order_notifications_enabled', 'is_promo_notifications_enabled',
            'is_dark_mode_enabled', 'preferred_language',
            'date_joined', 'is_staff'
        ]
        read_only_fields = ['id', 'phone', 'membership_tier', 'beans_balance', 'total_beans_earned', 'date_joined', 'is_staff', 'store_details']


class UserAddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserAddress
        fields = ['id', 'label', 'address_line', 'city', 'is_default', 'created_at']
        read_only_fields = ['id', 'created_at']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)
