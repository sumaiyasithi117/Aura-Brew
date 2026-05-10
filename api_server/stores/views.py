from rest_framework import generics
from rest_framework.permissions import AllowAny
from .models import Store
from .serializers import StoreSerializer


class StoreListView(generics.ListAPIView):
    """GET /api/v1/stores/ — list active stores."""
    queryset = Store.objects.filter(is_active=True)
    serializer_class = StoreSerializer
    permission_classes = [AllowAny]
    pagination_class = None


class StoreDetailView(generics.RetrieveAPIView):
    """GET /api/v1/stores/<id>/ — store detail."""
    queryset = Store.objects.filter(is_active=True)
    serializer_class = StoreSerializer
    permission_classes = [AllowAny]
