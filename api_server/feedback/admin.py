from django.contrib import admin
from .models import Feedback


@admin.register(Feedback)
class FeedbackAdmin(admin.ModelAdmin):
    list_display = ('user', 'order', 'service_rating', 'taste_satisfaction', 'created_at')
    list_filter = ('service_rating', 'created_at')
    search_fields = ('user__full_name', 'suggestions')
    readonly_fields = ('created_at',)
