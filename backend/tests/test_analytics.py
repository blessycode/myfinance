import pytest
from decimal import Decimal
from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from apps.accounts.models import User
from apps.financial_accounts.models import FinancialAccount
from apps.categories.models import Category, CategoryType
from apps.transactions.services import TransactionLedgerService
from apps.transactions.models import TransactionType

@pytest.mark.django_db
class TestAnalytics:
    @pytest.fixture
    def client_with_data(self, client):
        user = User.objects.create_user(email='analytics_user@example.com', password='Password123!')
        token = str(RefreshToken.for_user(user).access_token)
        client.defaults['HTTP_AUTHORIZATION'] = f'Bearer {token}'

        acc = FinancialAccount.objects.create(
            user=user, name='Primary USD', currency='USD',
            opening_balance=Decimal('5000.00'), current_balance=Decimal('5000.00')
        )
        cat_food = Category.objects.create(user=user, name='Dining', type=CategoryType.EXPENSE)
        cat_travel = Category.objects.create(user=user, name='Travel', type=CategoryType.EXPENSE)

        today = timezone.now().date()
        TransactionLedgerService.post_transaction(
            user=user, account=acc, transaction_type=TransactionType.INCOME,
            amount=Decimal('3000.00'), currency='USD', description='Salary', transaction_date=today
        )
        TransactionLedgerService.post_transaction(
            user=user, account=acc, transaction_type=TransactionType.EXPENSE,
            amount=Decimal('400.00'), currency='USD', description='Food', transaction_date=today, category=cat_food
        )
        TransactionLedgerService.post_transaction(
            user=user, account=acc, transaction_type=TransactionType.EXPENSE,
            amount=Decimal('200.00'), currency='USD', description='Taxi', transaction_date=today, category=cat_travel
        )

        return client

    def test_dashboard_analytics_endpoint(self, client_with_data):
        url = reverse('analytics-dashboard')
        res = client_with_data.get(url)
        assert res.status_code == status.HTTP_200_OK
        data = res.data['data']

        assert Decimal(str(data['monthly_income'])) == Decimal('3000.00')
        assert Decimal(str(data['monthly_expense'])) == Decimal('600.00')
        assert Decimal(str(data['net_savings'])) == Decimal('2400.00')
        assert 'insights' in data
        assert len(data['insights']) > 0

    def test_spending_breakdown_donut_chart_endpoint(self, client_with_data):
        url = reverse('analytics-spending-breakdown')
        res = client_with_data.get(url)
        assert res.status_code == status.HTTP_200_OK
        breakdown = res.data['data']

        assert len(breakdown) == 2
        # Dining was 400 out of 600 total (66.7%)
        assert breakdown[0]['category_name'] == 'Dining'
        assert Decimal(str(breakdown[0]['amount'])) == Decimal('400.00')
