import pytest
from decimal import Decimal
from django.urls import reverse
from rest_framework import status
from apps.currencies.models import Currency
from apps.exchange_rates.models import ExchangeRate
from apps.exchange_rates.services import CurrencyConversionService

@pytest.mark.django_db
class TestCurrencySystem:
    def test_currency_conversion_service_with_exact_decimals(self):
        usd = Currency.objects.create(code='USD', name='US Dollar', symbol='$')
        eur = Currency.objects.create(code='EUR', name='Euro', symbol='€')
        ExchangeRate.objects.create(
            base_currency=usd,
            target_currency=eur,
            rate=Decimal('0.920000')
        )

        amount = Decimal('100.00')
        converted, rate = CurrencyConversionService.convert(amount, 'USD', 'EUR')
        assert converted == Decimal('92.00')
        assert rate == Decimal('0.920000')

    def test_conversion_api_endpoint(self, client):
        url = reverse('exchange-rates-convert')
        payload = {
            'amount': '150.00',
            'from_currency': 'USD',
            'to_currency': 'EUR'
        }
        res = client.post(url, payload, content_type='application/json')
        assert res.status_code == status.HTTP_200_OK
        assert 'converted_amount' in res.data['data']
        assert 'exchange_rate' in res.data['data']
        assert res.data['data']['to_currency'] == 'EUR'
