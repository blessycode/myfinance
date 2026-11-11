import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings
from apps.financial_accounts.models import FinancialAccount
from apps.transactions.models import Transaction

class DebtType(models.TextChoices):
    BORROWED = 'borrowed', 'Money I Owe (Payable)'
    LENT = 'lent', 'Money Owed to Me (Receivable)'
    CREDIT_CARD = 'credit_card', 'Credit Card Balance'
    LOAN = 'loan', 'Formal Loan'

class Debt(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='debts')
    name = models.CharField(max_length=120)
    debt_type = models.CharField(max_length=20, choices=DebtType.choices, default=DebtType.BORROWED)
    counterparty = models.CharField(max_length=120, help_text="Person, lender, or financial entity")
    original_amount = models.DecimalField(max_digits=18, decimal_places=2)
    current_balance = models.DecimalField(max_digits=18, decimal_places=2)
    currency = models.CharField(max_length=6, default='USD')
    interest_rate = models.DecimalField(max_digits=5, decimal_places=2, default=Decimal('0.00'))
    due_date = models.DateField(null=True, blank=True)
    is_settled = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'debts'
        verbose_name = 'Debt'
        verbose_name_plural = 'Debts'
        ordering = ['due_date', '-created_at']

    def __str__(self):
        return f"{self.name} ({self.counterparty}): {self.currency} {self.current_balance}"

class DebtPayment(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    debt = models.ForeignKey(Debt, on_delete=models.CASCADE, related_name='payments')
    account = models.ForeignKey(FinancialAccount, on_delete=models.CASCADE)
    transaction = models.ForeignKey(Transaction, on_delete=models.SET_NULL, null=True, blank=True)
    amount = models.DecimalField(max_digits=18, decimal_places=2)
    currency = models.CharField(max_length=6)
    payment_date = models.DateField()
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'debt_payments'
        ordering = ['-payment_date']
