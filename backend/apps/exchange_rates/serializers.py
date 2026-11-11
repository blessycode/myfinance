from rest_framework import serializers
from .models import ExchangeRate

class ExchangeRateSerializer(serializers.ModelSerializer):
    base_currency = serializers.CharField(source='base_currency.code')
    target_currency = serializers.CharField(source='target_currency.code')

    class Meta:
        model = ExchangeRate
        fields = ['id', 'base_currency', 'target_currency', 'rate', 'source', 'timestamp']

class CurrencyConversionRequestSerializer(serializers.Serializer):
    amount = serializers.DecimalField(max_digits=18, decimal_places=2)
    from_currency = serializers.CharField(max_length=6)
    to_currency = serializers.CharField(max_length=6)

class CurrencyConversionResponseSerializer(serializers.Serializer):
    original_amount = serializers.DecimalField(max_digits=18, decimal_places=2)
    from_currency = serializers.CharField()
    converted_amount = serializers.DecimalField(max_digits=18, decimal_places=2)
    to_currency = serializers.CharField()
    exchange_rate = serializers.DecimalField(max_digits=18, decimal_places=6)
    valuation_date = serializers.DateTimeField()
