from django.db import models


class Store(models.Model):
    """Physical store / pickup location."""

    name = models.CharField(max_length=200)
    address = models.TextField()
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=50)
    zip_code = models.CharField(max_length=10)
    phone = models.CharField(max_length=15, blank=True)
    is_active = models.BooleanField(default=True)
    opening_time = models.TimeField(null=True, blank=True)
    closing_time = models.TimeField(null=True, blank=True)

    class Meta:
        db_table = 'stores'
        ordering = ['name']

    def __str__(self):
        return f'{self.name} — {self.city}'
