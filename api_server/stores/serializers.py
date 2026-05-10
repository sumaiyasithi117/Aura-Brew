from rest_framework import serializers
from .models import Store


class StoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = Store
        fields = [
            'id', 'name', 'address', 'city', 'state',
            'zip_code', 'phone', 'opening_time', 'closing_time', 'is_active',
        ]
