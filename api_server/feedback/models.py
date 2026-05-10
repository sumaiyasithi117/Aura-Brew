from django.db import models
from django.conf import settings


class Feedback(models.Model):
    """User feedback for an order."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='feedbacks',
    )
    order = models.OneToOneField(
        'orders.Order',
        on_delete=models.CASCADE,
        related_name='feedback',
        null=True,
        blank=True,
    )
    service_rating = models.PositiveSmallIntegerField(
        help_text='1-5 star rating for service quality'
    )
    taste_satisfaction = models.PositiveSmallIntegerField(
        help_text='0-100 taste satisfaction percentage'
    )
    tags = models.JSONField(default=list, blank=True, help_text='e.g. ["Fast Service", "Friendly Barista"]')
    suggestions = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'feedbacks'
        ordering = ['-created_at']

    def __str__(self):
        return f'Feedback by {self.user.full_name} — {self.service_rating}★'
