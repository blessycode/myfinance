import pytest
from decimal import Decimal
from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from apps.accounts.models import User
from apps.categories.models import Category, CategoryType
from apps.financial_accounts.models import FinancialAccount
from apps.budgets.models import Budget
from apps.savings_goals.models import SavingsGoal
from apps.transactions.services import TransactionLedgerService
from apps.transactions.models import TransactionType

@pytest.mark.django_db
class TestBudgetsAndSavingsGoals:
    @pytest.fixture
    def setup_data(self, client):
        user = User.objects.create_user(email='budget_user@example.com', password='Password123!')
        token = str(RefreshToken.for_user(user).access_token)
        client.defaults['HTTP_AUTHORIZATION'] = f'Bearer {token}'

        acc = FinancialAccount.objects.create(
            user=user, name='Main Checking', currency='USD',
            opening_balance=Decimal('2000.00'), current_balance=Decimal('2000.00')
        )
        cat = Category.objects.create(user=user, name='Food & Dining', type=CategoryType.EXPENSE)
        return client, user, acc, cat

    def test_budget_spent_calculation(self, setup_data):
        client, user, acc, cat = setup_data
        start = timezone.now().date().replace(day=1)
        end = start.replace(day=28)

        budget = Budget.objects.create(
            user=user, name='Food Budget', category=cat, amount=Decimal('500.00'),
            currency='USD', start_date=start, end_date=end
        )

        TransactionLedgerService.post_transaction(
            user=user, account=acc, transaction_type=TransactionType.EXPENSE,
            amount=Decimal('150.00'), currency='USD', description='Lunch',
            transaction_date=start, category=cat
        )

        assert budget.calculate_spent() == Decimal('150.00')

        url = reverse('budget-progress', kwargs={'pk': budget.id})
        res = client.get(url)
        assert res.status_code == status.HTTP_200_OK
        assert Decimal(str(res.data['data']['spent'])) == Decimal('150.00')
        assert Decimal(str(res.data['data']['remaining'])) == Decimal('350.00')

    def test_goal_contribution_deducts_account_atomically(self, setup_data):
        client, user, acc, _ = setup_data
        goal = SavingsGoal.objects.create(
            user=user, name='New Laptop', target_amount=Decimal('1200.00'),
            currency='USD', target_date=timezone.now().date() + timezone.timedelta(days=90)
        )

        url = reverse('goal-contribute', kwargs={'pk': goal.id})
        payload = {
            'from_account': str(acc.id),
            'amount': '300.00',
            'note': 'Initial deposit'
        }
        res = client.post(url, payload, content_type='application/json')
        assert res.status_code == status.HTTP_201_CREATED

        acc.refresh_from_db()
        goal.refresh_from_db()
        assert acc.current_balance == Decimal('1700.00') # Deducted from checking
        assert goal.current_amount == Decimal('300.00')   # Credited to goal
        assert goal.contributions.count() == 1
