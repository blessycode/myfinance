import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings
from django.db.models import Sum
from apps.categories.models import Category
from apps.exchange_rates.services import CurrencyConversionService

class BudgetPeriod(models.TextChoices):
    MONTHLY = 'monthly', 'Monthly'
    WEEKLY = 'weekly', 'Weekly'
    CUSTOM = 'custom', 'Custom Period'

class Budget(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='budgets')
    name = models.CharField(max_length=120)
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='budgets')
    amount = models.DecimalField('Budget Limit', max_digits=18, decimal_places=2)
    currency = models.CharField(max_length=6, default='USD')
    period = models.CharField(max_length=20, choices=BudgetPeriod.choices, default=BudgetPeriod.MONTHLY)
    start_date = models.DateField()
    end_date = models.DateField()
    alert_threshold = models.DecimalField(max_digits=5, decimal_places=2, default=Decimal('0.80'))
    color = models.CharField(max_length=20, default='#10B981')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'budgets'
        verbose_name = 'Budget'
        verbose_name_plural = 'Budgets'
        ordering = ['-start_date']

    def __str__(self):
        return f"{self.name} - {self.currency} {self.amount}"

    def calculate_spent(self) -> Decimal:
        """Calculates actual spending in budget category within time envelope."""
        from apps.transactions.models import Transaction, TransactionType

        trxs = Transaction.objects.filter(
            user=self.user,
            category=self.category,
            transaction_type=TransactionType.EXPENSE,
            transaction_date__gte=self.start_date,
            transaction_date__lte=self.end_date,
            is_reversed=False
        )

        total = Decimal('0.00')
        for t in trxs:
            converted, _ = CurrencyConversionService.convert(t.amount, t.currency, self.currency)
            total += converted
        return total
