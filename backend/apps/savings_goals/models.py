import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings
from apps.financial_accounts.models import FinancialAccount
from apps.transactions.models import Transaction

class SavingsGoal(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='savings_goals')
    name = models.CharField(max_length=120)
    emoji = models.CharField(max_length=10, default='🎯')
    target_amount = models.DecimalField(max_digits=18, decimal_places=2)
    current_amount = models.DecimalField(max_digits=18, decimal_places=2, default=Decimal('0.00'))
    currency = models.CharField(max_length=6, default='USD')
    target_date = models.DateField()
    description = models.TextField(blank=True)
    color = models.CharField(max_length=20, default='#059669')
    is_completed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'savings_goals'
        verbose_name = 'Savings Goal'
        verbose_name_plural = 'Savings Goals'
        ordering = ['target_date']

    def __str__(self):
        return f"{self.name} ({self.currency} {self.current_amount} / {self.target_amount})"

class GoalContribution(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    goal = models.ForeignKey(SavingsGoal, on_delete=models.CASCADE, related_name='contributions')
    from_account = models.ForeignKey(FinancialAccount, on_delete=models.CASCADE)
    transaction = models.ForeignKey(Transaction, on_delete=models.SET_NULL, null=True, blank=True)
    amount = models.DecimalField(max_digits=18, decimal_places=2)
    currency = models.CharField(max_length=6)
    note = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'goal_contributions'
        ordering = ['-created_at']
