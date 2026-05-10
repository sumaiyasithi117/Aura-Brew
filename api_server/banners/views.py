from rest_framework import generics
from rest_framework.permissions import AllowAny
from .models import Banner
from .serializers import BannerSerializer


class BannerListView(generics.ListAPIView):
    """GET /api/v1/banners/ — list active banners."""
    queryset = Banner.objects.filter(is_active=True)
    serializer_class = BannerSerializer
    permission_classes = [AllowAny]
    pagination_class = None
