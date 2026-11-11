from decimal import Decimal
from django.db import transaction as db_transaction
from django.core.exceptions import ValidationError
from django.utils import timezone
from .models import Transaction, TransactionType, JournalEntry, LedgerEntry
from apps.financial_accounts.models import FinancialAccount
from apps.categories.models import Category
from apps.exchange_rates.services import CurrencyConversionService
from common.utilities.money import round_money

class TransactionLedgerService:
    @classmethod
    @db_transaction.atomic
    def post_transaction(
        cls,
        user,
        account: FinancialAccount,
        transaction_type: str,
        amount: Decimal,
        currency: str,
        description: str,
        transaction_date,
        category: Category = None,
        merchant: str = '',
        payment_method: str = 'bank_transfer',
        notes: str = '',
        receipt_attachment = None,
        idempotency_key: str = None
    ) -> Transaction:
        # Check idempotency
        if idempotency_key:
            existing = Transaction.objects.filter(user=user, idempotency_key=idempotency_key).first()
            if existing:
                return existing

        amount = round_money(amount)
        if amount <= Decimal('0.00'):
            raise ValidationError('Transaction amount must be strictly positive.')

        # Ensure account belongs to user
        if account.user != user:
            raise ValidationError('Unauthorized access to specified financial account.')

        # Snapshot exchange rate relative to USD
        _, rate = CurrencyConversionService.convert(Decimal('1.0'), currency, 'USD')

        # Create Transaction record
        trx = Transaction.objects.create(
            user=user,
            account=account,
            transaction_type=transaction_type,
            category=category,
            amount=amount,
            currency=currency,
            description=description,
            merchant=merchant,
            transaction_date=transaction_date,
            payment_method=payment_method,
            notes=notes,
            receipt_attachment=receipt_attachment,
            idempotency_key=idempotency_key,
            exchange_rate_snapshot=rate
        )

        # Create Journal Entry
        journal = JournalEntry.objects.create(
            transaction=trx,
            description=f"Posting {transaction_type}: {description}"
        )

        # Update Account Balance atomically
        if transaction_type in (TransactionType.INCOME, TransactionType.INVESTMENT):
            # Income increases account balance
            account.current_balance = round_money(account.current_balance + amount)
            account.save(update_fields=['current_balance', 'updated_at'])

            LedgerEntry.objects.create(
                journal_entry=journal,
                account=account,
                entry_type=LedgerEntry.ENTRY_DEBIT,
                amount=amount,
                currency=currency
            )
        elif transaction_type in (TransactionType.EXPENSE, TransactionType.SAVINGS_CONTRIBUTION, TransactionType.DEBT_REPAYMENT):
            # Expense decreases account balance
            account.current_balance = round_money(account.current_balance - amount)
            account.save(update_fields=['current_balance', 'updated_at'])

            LedgerEntry.objects.create(
                journal_entry=journal,
                account=account,
                entry_type=LedgerEntry.ENTRY_CREDIT,
                amount=amount,
                currency=currency
            )

        return trx

    @classmethod
    @db_transaction.atomic
    def post_transfer(
        cls,
        user,
        from_account: FinancialAccount,
        to_account: FinancialAccount,
        amount: Decimal,
        description: str,
        transaction_date,
        idempotency_key: str = None
    ) -> Transaction:
        if from_account == to_account:
            raise ValidationError('Source and destination accounts for a transfer cannot be identical.')

        if from_account.user != user or to_account.user != user:
            raise ValidationError('Both accounts involved in transfer must belong to authenticated user.')

        amount = round_money(amount)
        if amount <= Decimal('0.00'):
            raise ValidationError('Transfer amount must be strictly greater than 0.00.')

        # Calculate received amount in destination currency
        if from_account.currency == to_account.currency:
            received_amount = amount
            rate = Decimal('1.000000')
        else:
            received_amount, rate = CurrencyConversionService.convert(
                amount, from_account.currency, to_account.currency
            )

        # Deduct from source account
        from_account.current_balance = round_money(from_account.current_balance - amount)
        from_account.save(update_fields=['current_balance', 'updated_at'])

        # Credit destination account
        to_account.current_balance = round_money(to_account.current_balance + received_amount)
        to_account.save(update_fields=['current_balance', 'updated_at'])

        # Record Transfer Transaction (does NOT count towards income/expense)
        trx = Transaction.objects.create(
            user=user,
            account=from_account,
            to_account=to_account,
            transaction_type=TransactionType.TRANSFER,
            amount=amount,
            currency=from_account.currency,
            description=description or f"Transfer from {from_account.name} to {to_account.name}",
            transaction_date=transaction_date,
            idempotency_key=idempotency_key,
            exchange_rate_snapshot=rate
        )

        journal = JournalEntry.objects.create(
            transaction=trx,
            description=f"Transfer: {from_account.name} -> {to_account.name}"
        )

        # Double entry: Credit source account, Debit destination account
        LedgerEntry.objects.create(
            journal_entry=journal,
            account=from_account,
            entry_type=LedgerEntry.ENTRY_CREDIT,
            amount=amount,
            currency=from_account.currency
        )

        LedgerEntry.objects.create(
            journal_entry=journal,
            account=to_account,
            entry_type=LedgerEntry.ENTRY_DEBIT,
            amount=received_amount,
            currency=to_account.currency
        )

        return trx

    @classmethod
    @db_transaction.atomic
    def reverse_transaction(cls, user, transaction: Transaction, reason: str = '') -> Transaction:
        if transaction.user != user:
            raise ValidationError('Unauthorized attempt to reverse transaction.')
        if transaction.is_reversed:
            raise ValidationError('This transaction has already been reversed.')

        # Post inverse movement
        account = transaction.account
        inv_type = (
            TransactionType.EXPENSE if transaction.transaction_type == TransactionType.INCOME
            else TransactionType.INCOME
        )

        if transaction.transaction_type == TransactionType.INCOME:
            account.current_balance = round_money(account.current_balance - transaction.amount)
        elif transaction.transaction_type == TransactionType.EXPENSE:
            account.current_balance = round_money(account.current_balance + transaction.amount)
        elif transaction.transaction_type == TransactionType.TRANSFER and transaction.to_account:
            # Reverse transfer
            account.current_balance = round_money(account.current_balance + transaction.amount)
            # Revert destination
            to_acc = transaction.to_account
            dest_amount, _ = CurrencyConversionService.convert(
                transaction.amount, transaction.currency, to_acc.currency
            )
            to_acc.current_balance = round_money(to_acc.current_balance - dest_amount)
            to_acc.save(update_fields=['current_balance', 'updated_at'])

        account.save(update_fields=['current_balance', 'updated_at'])

        # Mark original as reversed
        transaction.is_reversed = True
        transaction.save(update_fields=['is_reversed'])

        # Create reversal transaction record
        reversal_trx = Transaction.objects.create(
            user=user,
            account=account,
            transaction_type=inv_type,
            category=transaction.category,
            amount=transaction.amount,
            currency=transaction.currency,
            description=f"REVERSAL: {transaction.description}. Reason: {reason or 'User request'}",
            transaction_date=timezone.now().date(),
            reversal_of=transaction
        )

        return reversal_trx
