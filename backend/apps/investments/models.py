import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings

class AssetType(models.TextChoices):
    STOCK = 'stock', 'Stock'
    ETF = 'etf', 'ETF'
    CRYPTO = 'crypto', 'Cryptocurrency'
    BOND = 'bond', 'Bond'
    MUTUAL_FUND = 'mutual_fund', 'Mutual Fund'
    REAL_ESTATE = 'real_estate', 'Real Estate'
    OTHER = 'other', 'Other'

class Investment(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='investments')
    name = models.CharField(max_length=120)
    symbol = models.CharField(max_length=20, blank=True)
    asset_type = models.CharField(max_length=20, choices=AssetType.choices, default=AssetType.STOCK)
    units = models.DecimalField(max_digits=18, decimal_places=6)
    purchase_price = models.DecimalField('Cost Basis Per Unit', max_digits=18, decimal_places=4)
    current_price = models.DecimalField('Current Price Per Unit', max_digits=18, decimal_places=4)
    currency = models.CharField(max_length=6, default='USD')
    notes = models.TextField(blank=True)
    last_valuation_date = models.DateField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'investments'
        verbose_name = 'Investment'
        verbose_name_plural = 'Investments'
        ordering = ['name']

    @property
    def total_invested(self) -> Decimal:
        return (self.units * self.purchase_price).quantize(Decimal('0.01'))

    @property
    def current_valuation(self) -> Decimal:
        return (self.units * self.current_price).quantize(Decimal('0.01'))

    @property
    def unrealized_pl(self) -> Decimal:
        return self.current_valuation - self.total_invested

    @property
    def percentage_return(self) -> float:
        if self.total_invested == Decimal('0.00'):
            return 0.0
        return float(((self.current_valuation - self.total_invested) / self.total_invested) * 100)
