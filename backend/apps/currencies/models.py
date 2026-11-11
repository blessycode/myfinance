from django.db import models

class Currency(models.Model):
    code = models.CharField(max_length=6, primary_key=True) # e.g. USD, EUR, GBP, ZAR, ZWG, BWP
    name = models.CharField(max_length=80)
    symbol = models.CharField(max_length=10)
    decimal_precision = models.PositiveSmallIntegerField(default=2)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'currencies'
        verbose_name = 'Currency'
        verbose_name_plural = 'Currencies'
        ordering = ['code']

    def __str__(self):
        return f"{self.code} ({self.symbol})"
