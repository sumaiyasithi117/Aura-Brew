from django.db import models


class Banner(models.Model):
    """Promotional banners displayed on home and tea screens."""

    title = models.CharField(max_length=200)
    subtitle = models.TextField(blank=True)
    badge_text = models.CharField(max_length=50, blank=True, help_text='e.g. SEASONAL SELECTION, NEW ARRIVAL')
    image = models.ImageField(upload_to='banners/', blank=True, null=True)
    link_product = models.ForeignKey(
        'products.Product',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='banners',
    )
    is_active = models.BooleanField(default=True)
    display_order = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'banners'
        ordering = ['display_order']

    def __str__(self):
        return self.title
