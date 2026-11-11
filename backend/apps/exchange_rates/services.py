from decimal import Decimal
from django.utils import timezone
from .models import ExchangeRate
from common.utilities.money import round_money

class CurrencyConversionService:
    # Default benchmark rates against USD if none in DB yet
    FALLBACK_USD_RATES = {
        'USD': Decimal('1.000000'),
        'EUR': Decimal('0.917431'),  # 1 USD = 0.917 EUR (~1.09 EUR/USD)
        'GBP': Decimal('0.781250'),  # 1 USD = 0.781 GBP (~1.28 GBP/USD)
        'ZAR': Decimal('18.181818'), # 1 USD = 18.18 ZAR (~0.055 USD/ZAR)
        'ZWG': Decimal('26.315789'), # 1 USD = 26.32 ZiG (~0.038 USD/ZiG)
        'BWP': Decimal('13.513514'), # 1 USD = 13.51 BWP (~0.074 USD/BWP)
    }

    @classmethod
    def get_latest_rate(cls, from_currency: str, to_currency: str) -> Decimal:
        if from_currency == to_currency:
            return Decimal('1.000000')

        # Check direct rate
        direct = ExchangeRate.objects.filter(
            base_currency_id=from_currency,
            target_currency_id=to_currency
        ).order_by('-timestamp').first()

        if direct:
            return direct.rate

        # Check inverse rate
        inverse = ExchangeRate.objects.filter(
            base_currency_id=to_currency,
            target_currency_id=from_currency
        ).order_by('-timestamp').first()

        if inverse and inverse.rate > Decimal('0'):
            return Decimal('1.000000') / inverse.rate

        # Triangular conversion via USD fallback
        from_to_usd = cls.FALLBACK_USD_RATES.get(from_currency, Decimal('1.0'))
        to_to_usd = cls.FALLBACK_USD_RATES.get(to_currency, Decimal('1.0'))

        # 1 from = (1 / from_to_usd) USD
        # USD to to_currency = to_to_usd
        rate = (Decimal('1.0') / from_to_usd) * to_to_usd
        return rate

    @classmethod
    def convert(cls, amount: Decimal, from_currency: str, to_currency: str) -> tuple[Decimal, Decimal]:
        """
        Converts amount from one currency to another using exact decimal arithmetic.
        Returns: (converted_amount, rate_used)
        """
        if from_currency == to_currency:
            return round_money(amount), Decimal('1.000000')

        rate = cls.get_latest_rate(from_currency, to_currency)
        converted = amount * rate
        return round_money(converted), rate
