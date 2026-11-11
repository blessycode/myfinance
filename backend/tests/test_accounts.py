import pytest
from decimal import Decimal
from django.urls import reverse
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from apps.accounts.models import User
from apps.financial_accounts.models import FinancialAccount, AccountType

@pytest.mark.django_db
class TestFinancialAccounts:
    @pytest.fixture
    def authenticated_client(self, client):
        user = User.objects.create_user(email='finance_user@example.com', password='Password123!')
        token = str(RefreshToken.for_user(user).access_token)
        client.defaults['HTTP_AUTHORIZATION'] = f'Bearer {token}'
        client.user = user
        return client

    def test_create_account(self, authenticated_client):
        url = reverse('account-list-create')
        payload = {
            'name': 'Everyday Checking',
            'account_type': AccountType.BANK,
            'currency': 'USD',
            'opening_balance': '1500.00',
            'institution_name': 'Barclays'
        }
        response = authenticated_client.post(url, payload, content_type='application/json')
        assert response.status_code == status.HTTP_201_CREATED
        account_data = response.data['data']
        assert account_data['name'] == 'Everyday Checking'
        assert Decimal(account_data['current_balance']) == Decimal('1500.00')

    def test_list_accounts_isolated_to_user(self, authenticated_client):
        other_user = User.objects.create_user(email='other@example.com', password='Password123!')
        FinancialAccount.objects.create(user=other_user, name='Other Account', currency='USD', opening_balance=Decimal('500.00'))

        FinancialAccount.objects.create(user=authenticated_client.user, name='My Account', currency='USD', opening_balance=Decimal('200.00'))

        url = reverse('account-list-create')
        response = authenticated_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert response.data['data']['count'] == 1
        assert response.data['data']['results'][0]['name'] == 'My Account'
