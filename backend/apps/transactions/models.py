import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings
from apps.financial_accounts.models import FinancialAccount
from apps.categories.models import Category

class TransactionType(models.TextChoices):
    INCOME = 'income', 'Income'
    EXPENSE = 'expense', 'Expense'
    TRANSFER = 'transfer', 'Account Transfer'
    SAVINGS_CONTRIBUTION = 'savings_contribution', 'Savings Contribution'
    DEBT_REPAYMENT = 'debt_repayment', 'Debt Repayment'
    INVESTMENT = 'investment', 'Investment Activity'

class PaymentMethod(models.TextChoices):
    CASH = 'cash', 'Cash'
    CREDIT_CARD = 'credit_card', 'Credit Card'
    DEBIT_CARD = 'debit_card', 'Debit Card'
    BANK_TRANSFER = 'bank_transfer', 'Bank Transfer'
    WALLET = 'wallet', 'Digital Wallet'

class Transaction(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='transactions')
    account = models.ForeignKey(FinancialAccount, on_delete=models.CASCADE, related_name='transactions')
    to_account = models.ForeignKey(
        FinancialAccount,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='incoming_transfers',
        help_text="Destination account if this is an inter-account transfer."
    )
    transaction_type = models.CharField(max_length=30, choices=TransactionType.choices, db_index=True)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, related_name='transactions')
    amount = models.DecimalField(max_digits=18, decimal_places=2)
    currency = models.CharField(max_length=6, default='USD')
    description = models.CharField(max_length=255)
    merchant = models.CharField(max_length=150, blank=True)
    transaction_date = models.DateField(db_index=True)
    payment_method = models.CharField(max_length=30, choices=PaymentMethod.choices, default=PaymentMethod.BANK_TRANSFER)
    notes = models.TextField(blank=True)
    receipt_attachment = models.FileField(upload_to='receipts/%Y/%m/', null=True, blank=True)

    is_reversed = models.BooleanField(default=False)
    reversal_of = models.OneToOneField('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='reversed_by')
    idempotency_key = models.CharField(max_length=120, null=True, blank=True, db_index=True)
    exchange_rate_snapshot = models.DecimalField(max_digits=18, decimal_places=6, null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'financial_transactions'
        verbose_name = 'Financial Transaction'
        verbose_name_plural = 'Financial Transactions'
        ordering = ['-transaction_date', '-created_at']
        indexes = [
            models.Index(fields=['user', '-transaction_date']),
            models.Index(fields=['account', '-transaction_date']),
            models.Index(fields=['transaction_type', '-transaction_date']),
        ]

    def __str__(self):
        return f"{self.get_transaction_type_display()}: {self.currency} {self.amount} - {self.description}"

class JournalEntry(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    transaction = models.ForeignKey(Transaction, on_delete=models.CASCADE, related_name='journal_entries')
    description = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'journal_entries'
        ordering = ['-created_at']

class LedgerEntry(models.Model):
    ENTRY_DEBIT = 'debit'
    ENTRY_CREDIT = 'credit'
    ENTRY_TYPES = [
        (ENTRY_DEBIT, 'Debit'),
        (ENTRY_CREDIT, 'Credit'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    journal_entry = models.ForeignKey(JournalEntry, on_delete=models.CASCADE, related_name='ledger_entries')
    account = models.ForeignKey(FinancialAccount, on_delete=models.CASCADE, related_name='ledger_entries')
    entry_type = models.CharField(max_length=10, choices=ENTRY_TYPES)
    amount = models.DecimalField(max_digits=18, decimal_places=2)
    currency = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'ledger_entries'
        ordering = ['-created_at']
