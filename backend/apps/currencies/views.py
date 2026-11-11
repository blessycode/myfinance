from rest_framework import generics, permissions
from drf_spectacular.utils import extend_schema
from .models import Currency
from .serializers import CurrencySerializer

class CurrencyListView(generics.ListAPIView):
    queryset = Currency.objects.filter(is_active=True)
    serializer_class = CurrencySerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None

    @extend_schema(summary="List all supported currencies with symbols and precision")
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
