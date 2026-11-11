import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings
from apps.categories.models import Category
from apps.financial_accounts.models import FinancialAccount

class Frequency(models.TextChoices):
    DAILY = 'daily', 'Daily'
    WEEKLY = 'weekly', 'Weekly'
    MONTHLY = 'monthly', 'Monthly'
    QUARTERLY = 'quarterly', 'Quarterly'
    YEARLY = 'yearly', 'Yearly'

class Subscription(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='subscriptions')
    name = models.CharField(max_length=120)
    merchant = models.CharField(max_length=150, blank=True)
    amount = models.DecimalField(max_digits=18, decimal_places=2)
    currency = models.CharField(max_length=6, default='USD')
    frequency = models.CharField(max_length=20, choices=Frequency.choices, default=Frequency.MONTHLY)
    next_due_date = models.DateField(db_index=True)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True)
    account = models.ForeignKey(FinancialAccount, on_delete=models.SET_NULL, null=True, blank=True)
    remind_days_before = models.PositiveSmallIntegerField(default=3)
    icon = models.CharField(max_length=60, default='receipt_long_rounded')
    color = models.CharField(max_length=20, default='#6366F1')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'subscriptions'
        verbose_name = 'Subscription'
        verbose_name_plural = 'Subscriptions'
        ordering = ['next_due_date']

    def __str__(self):
        return f"{self.name} ({self.currency} {self.amount}/{self.frequency})"
