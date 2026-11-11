import pytest
from decimal import Decimal
from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from apps.accounts.models import User
from apps.financial_accounts.models import FinancialAccount
from apps.transactions.models import Transaction, TransactionType, LedgerEntry
from apps.transactions.services import TransactionLedgerService

@pytest.mark.django_db
class TestTransactionsAndLedger:
    @pytest.fixture
    def setup_data(self, client):
        user = User.objects.create_user(email='ledger_user@example.com', password='Password123!')
        token = str(RefreshToken.for_user(user).access_token)
        client.defaults['HTTP_AUTHORIZATION'] = f'Bearer {token}'

        acc1 = FinancialAccount.objects.create(
            user=user, name='Checking USD', currency='USD',
            opening_balance=Decimal('1000.00'), current_balance=Decimal('1000.00')
        )
        acc2 = FinancialAccount.objects.create(
            user=user, name='Savings USD', currency='USD',
            opening_balance=Decimal('500.00'), current_balance=Decimal('500.00')
        )
        return client, user, acc1, acc2

    def test_post_income_updates_balance_and_ledger(self, setup_data):
        client, user, acc1, _ = setup_data
        url = reverse('transaction-list-create')
        payload = {
            'account': str(acc1.id),
            'transaction_type': TransactionType.INCOME,
            'amount': '250.00',
            'currency': 'USD',
            'description': 'Freelance payment',
            'transaction_date': str(timezone.now().date())
        }
        response = client.post(url, payload, content_type='application/json')
        assert response.status_code == status.HTTP_201_CREATED

        acc1.refresh_from_db()
        assert acc1.current_balance == Decimal('1250.00')

        trx = Transaction.objects.get(id=response.data['data']['id'])
        assert trx.journal_entries.count() == 1
        ledger_entries = trx.journal_entries.first().ledger_entries.all()
        assert ledger_entries.count() == 1
        assert ledger_entries.first().entry_type == LedgerEntry.ENTRY_DEBIT

    def test_post_expense_updates_balance_and_ledger(self, setup_data):
        client, user, acc1, _ = setup_data
        url = reverse('transaction-list-create')
        payload = {
            'account': str(acc1.id),
            'transaction_type': TransactionType.EXPENSE,
            'amount': '150.00',
            'currency': 'USD',
            'description': 'Grocery shopping',
            'transaction_date': str(timezone.now().date())
        }
        response = client.post(url, payload, content_type='application/json')
        assert response.status_code == status.HTTP_201_CREATED

        acc1.refresh_from_db()
        assert acc1.current_balance == Decimal('850.00')

    def test_inter_account_transfer_is_balanced_and_not_income_expense(self, setup_data):
        client, user, acc1, acc2 = setup_data
        url = reverse('transaction-transfer')
        payload = {
            'from_account': str(acc1.id),
            'to_account': str(acc2.id),
            'amount': '300.00',
            'description': 'Move to emergency savings',
            'transaction_date': str(timezone.now().date())
        }
        response = client.post(url, payload, content_type='application/json')
        assert response.status_code == status.HTTP_201_CREATED

        acc1.refresh_from_db()
        acc2.refresh_from_db()

        assert acc1.current_balance == Decimal('700.00')
        assert acc2.current_balance == Decimal('800.00')

        # Check summary endpoint does NOT include transfer in income or expense
        summary_url = reverse('transaction-summary')
        summary_res = client.get(summary_url)
        assert summary_res.status_code == status.HTTP_200_OK
        assert Decimal(summary_res.data['data']['total_income']) == Decimal('0.00')
        assert Decimal(summary_res.data['data']['total_expense']) == Decimal('0.00')

    def test_reversal_creates_counter_entry_and_restores_balance(self, setup_data):
        client, user, acc1, _ = setup_data
        trx = TransactionLedgerService.post_transaction(
            user=user,
            account=acc1,
            transaction_type=TransactionType.EXPENSE,
            amount=Decimal('100.00'),
            currency='USD',
            description='Accidental charge',
            transaction_date=timezone.now().date()
        )
        acc1.refresh_from_db()
        assert acc1.current_balance == Decimal('900.00')

        # Reverse transaction
        url = reverse('transaction-reverse', kwargs={'pk': trx.id})
        res = client.post(url, {'reason': 'Incorrect charge'}, content_type='application/json')
        assert res.status_code == status.HTTP_200_OK

        acc1.refresh_from_db()
        trx.refresh_from_db()
        assert trx.is_reversed is True
        assert acc1.current_balance == Decimal('1000.00') # Restored!
