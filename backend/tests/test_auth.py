import pytest
from django.urls import reverse
from rest_framework import status
from apps.accounts.models import User

@pytest.mark.django_db
class TestAuthentication:
    def test_user_registration_success(self, client):
        url = reverse('auth-register')
        payload = {
            'email': 'ayesha@example.com',
            'password': 'SecurePassword123!',
            'first_name': 'Ayesha',
            'last_name': 'Khan',
            'phone_number': '+1234567890',
            'preferred_currency': 'USD'
        }
        response = client.post(url, payload, content_type='application/json')
        assert response.status_code == status.HTTP_201_CREATED
        assert 'tokens' in response.data['data']
        assert 'access' in response.data['data']['tokens']
        assert User.objects.filter(email='ayesha@example.com').exists()

    def test_user_login_success(self, client):
        user = User.objects.create_user(email='testuser@example.com', password='Password123!')
        url = reverse('auth-login')
        payload = {'email': 'testuser@example.com', 'password': 'Password123!'}
        response = client.post(url, payload, content_type='application/json')
        assert response.status_code == status.HTTP_200_OK
        assert 'tokens' in response.data['data']

    def test_user_login_invalid_credentials(self, client):
        User.objects.create_user(email='testuser@example.com', password='Password123!')
        url = reverse('auth-login')
        payload = {'email': 'testuser@example.com', 'password': 'WrongPassword!'}
        response = client.post(url, payload, content_type='application/json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_current_user_me_endpoint(self, client):
        user = User.objects.create_user(email='me@example.com', password='Password123!', first_name='Ayesha')
        from rest_framework_simplejwt.tokens import RefreshToken
        token = str(RefreshToken.for_user(user).access_token)

        url = reverse('auth-me')
        response = client.get(url, HTTP_AUTHORIZATION=f'Bearer {token}')
        assert response.status_code == status.HTTP_200_OK
        assert response.data['data']['email'] == 'me@example.com'
        assert response.data['data']['first_name'] == 'Ayesha'
