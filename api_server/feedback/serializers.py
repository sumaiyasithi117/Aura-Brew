from rest_framework import serializers
from .models import Feedback


class FeedbackSerializer(serializers.ModelSerializer):
    class Meta:
        model = Feedback
        fields = [
            'id', 'order', 'service_rating', 'taste_satisfaction',
            'tags', 'suggestions', 'created_at',
        ]
        read_only_fields = ['id', 'created_at']

    def validate_service_rating(self, value):
        if not 1 <= value <= 5:
            raise serializers.ValidationError('Rating must be between 1 and 5.')
        return value

    def validate_taste_satisfaction(self, value):
        if not 0 <= value <= 100:
            raise serializers.ValidationError('Taste satisfaction must be between 0 and 100.')
        return value
