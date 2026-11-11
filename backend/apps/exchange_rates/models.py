import uuid
from decimal import Decimal
from django.db import models
from apps.currencies.models import Currency

class ExchangeRate(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    base_currency = models.ForeignKey(Currency, on_delete=models.CASCADE, related_name='base_rates')
    target_currency = models.ForeignKey(Currency, on_delete=models.CASCADE, related_name='target_rates')
    rate = models.DecimalField(max_digits=18, decimal_places=6)
    source = models.CharField(max_length=60, default='central_bank_composite')
    timestamp = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table = 'exchange_rates'
        verbose_name = 'Exchange Rate'
        verbose_name_plural = 'Exchange Rates'
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['base_currency', 'target_currency', '-timestamp']),
        ]

    def __str__(self):
        return f"1 {self.base_currency.code} = {self.rate} {self.target_currency.code} ({self.timestamp:%Y-%m-%d})"
