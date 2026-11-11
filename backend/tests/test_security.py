import pytest
from decimal import Decimal
from django.urls import reverse
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from apps.accounts.models import User
from apps.financial_accounts.models import FinancialAccount

@pytest.mark.django_db
class TestSecurityAndIsolation:
    def test_user_cannot_access_or_modify_another_users_account(self, client):
        user_alice = User.objects.create_user(email='alice@example.com', password='Password123!')
        user_bob = User.objects.create_user(email='bob@example.com', password='Password123!')

        alice_token = str(RefreshToken.for_user(user_alice).access_token)
        bob_token = str(RefreshToken.for_user(user_bob).access_token)

        # Alice creates an account
        alice_acc = FinancialAccount.objects.create(
            user=user_alice, name="Alice's Vault", currency='USD', opening_balance=Decimal('10000.00')
        )

        # Bob attempts to GET Alice's account detail
        url = reverse('account-detail', kwargs={'pk': alice_acc.id})
        res = client.get(url, HTTP_AUTHORIZATION=f'Bearer {bob_token}')
        assert res.status_code == status.HTTP_404_NOT_FOUND

        # Bob attempts to PATCH Alice's account
        res = client.patch(url, {'name': 'Hacked Vault'}, content_type='application/json', HTTP_AUTHORIZATION=f'Bearer {bob_token}')
        assert res.status_code == status.HTTP_404_NOT_FOUND

        # Bob attempts to DELETE Alice's account
        res = client.delete(url, HTTP_AUTHORIZATION=f'Bearer {bob_token}')
        assert res.status_code == status.HTTP_404_NOT_FOUND

        # Verify Alice's account remained untouched
        alice_acc.refresh_from_db()
        assert alice_acc.name == "Alice's Vault"
