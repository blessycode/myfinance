import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings

class AccountType(models.TextChoices):
    BANK = 'bank', 'Bank Account'
    CASH = 'cash', 'Cash Wallet'
    MOBILE_MONEY = 'mobile_money', 'Mobile Money'
    SAVINGS = 'savings', 'Savings Account'
    INVESTMENT = 'investment', 'Investment Account'
    CREDIT_CARD = 'credit_card', 'Credit Card'
    OTHER = 'other', 'Other'

class FinancialAccount(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='financial_accounts')
    name = models.CharField(max_length=120)
    account_type = models.CharField(max_length=30, choices=AccountType.choices, default=AccountType.BANK)
    currency = models.CharField(max_length=6, default='USD')
    opening_balance = models.DecimalField(max_digits=18, decimal_places=2, default=Decimal('0.00'))
    current_balance = models.DecimalField(max_digits=18, decimal_places=2, default=Decimal('0.00'))
    institution_name = models.CharField(max_length=120, blank=True)
    description = models.TextField(blank=True)
    color = models.CharField(max_length=20, default='#059669')
    icon = models.CharField(max_length=60, default='account_balance_rounded')

    is_active = models.BooleanField(default=True)
    is_archived = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'financial_accounts'
        verbose_name = 'Financial Account'
        verbose_name_plural = 'Financial Accounts'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} ({self.currency} {self.current_balance})"
