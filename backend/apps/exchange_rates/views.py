from django.utils import timezone
from rest_framework import generics, views, permissions, status
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from .models import ExchangeRate
from .serializers import (
    ExchangeRateSerializer,
    CurrencyConversionRequestSerializer,
    CurrencyConversionResponseSerializer
)
from .services import CurrencyConversionService

class ExchangeRateListView(generics.ListAPIView):
    queryset = ExchangeRate.objects.select_related('base_currency', 'target_currency').all()
    serializer_class = ExchangeRateSerializer
    permission_classes = [permissions.AllowAny]

    @extend_schema(summary="List latest recorded exchange rates")
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

class ConvertCurrencyView(views.APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        request=CurrencyConversionRequestSerializer,
        responses={200: CurrencyConversionResponseSerializer},
        summary="Convert an amount between currencies with audited rate snapshot"
    )
    def post(self, request):
        serializer = CurrencyConversionRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        amount = serializer.validated_data['amount']
        from_curr = serializer.validated_data['from_currency'].upper().strip()
        to_curr = serializer.validated_data['to_currency'].upper().strip()

        converted_amount, rate = CurrencyConversionService.convert(amount, from_curr, to_curr)

        data = {
            'original_amount': amount,
            'from_currency': from_curr,
            'converted_amount': converted_amount,
            'to_currency': to_curr,
            'exchange_rate': rate,
            'valuation_date': timezone.now()
        }
        return Response(data, status=status.HTTP_200_OK)
