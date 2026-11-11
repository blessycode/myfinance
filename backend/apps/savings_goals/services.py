from decimal import Decimal
from django.db import transaction as db_transaction
from django.core.exceptions import ValidationError
from django.utils import timezone
from .models import SavingsGoal, GoalContribution
from apps.financial_accounts.models import FinancialAccount
from apps.transactions.models import TransactionType
from apps.transactions.services import TransactionLedgerService
from apps.exchange_rates.services import CurrencyConversionService
from common.utilities.money import round_money

class GoalService:
    @classmethod
    @db_transaction.atomic
    def record_contribution(
        cls,
        user,
        goal: SavingsGoal,
        from_account: FinancialAccount,
        amount: Decimal,
        note: str = ''
    ) -> GoalContribution:
        if goal.user != user or from_account.user != user:
            raise ValidationError('Unauthorized access to goal or funding account.')

        amount = round_money(amount)
        if amount <= Decimal('0.00'):
            raise ValidationError('Contribution amount must be strictly greater than 0.00.')

        # Post financial movement to deduct from account
        trx = TransactionLedgerService.post_transaction(
            user=user,
            account=from_account,
            transaction_type=TransactionType.SAVINGS_CONTRIBUTION,
            amount=amount,
            currency=from_account.currency,
            description=f"Contribution to savings goal: {goal.name}",
            transaction_date=timezone.now().date(),
            notes=note
        )

        # Convert to goal currency if different
        converted_amount, _ = CurrencyConversionService.convert(amount, from_account.currency, goal.currency)

        # Update goal progress
        goal.current_amount = round_money(goal.current_amount + converted_amount)
        if goal.current_amount >= goal.target_amount:
            goal.is_completed = True
        goal.save(update_fields=['current_amount', 'is_completed'])

        # Create contribution log
        contribution = GoalContribution.objects.create(
            goal=goal,
            from_account=from_account,
            transaction=trx,
            amount=converted_amount,
            currency=goal.currency,
            note=note
        )

        return contribution
