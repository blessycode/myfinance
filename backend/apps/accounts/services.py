import uuid
from django.core.cache import cache
from django.core.mail import send_mail
from django.conf import settings
from rest_framework_simplejwt.tokens import RefreshToken
from .models import User

class AccountAuthService:
    @staticmethod
    def generate_tokens_for_user(user: User) -> dict:
        refresh = RefreshToken.for_user(user)
        return {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'user': {
                'id': str(user.id),
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'full_name': user.full_name,
            }
        }

    @staticmethod
    def send_verification_token(user: User) -> str:
        token = str(uuid.uuid4())
        cache_key = f'email_verification:{token}'
        cache.set(cache_key, str(user.id), timeout=86400) # 24 hours

        # In development, logged or sent via configured backend
        send_mail(
            subject=f'Verify your {settings.APP_NAME} Account',
            message=f'Hello {user.first_name or "there"},\n\nUse token {token} to verify your email.',
            from_email=settings.SUPPORT_EMAIL,
            recipient_list=[user.email],
            fail_silently=True
        )
        return token

    @staticmethod
    def verify_email_token(token: str) -> bool:
        cache_key = f'email_verification:{token}'
        user_id = cache.get(cache_key)
        if not user_id:
            return False
        try:
            user = User.objects.get(id=user_id)
            user.is_verified = True
            user.save(update_fields=['is_verified'])
            cache.delete(cache_key)
            return True
        except User.DoesNotExist:
            return False

    @staticmethod
    def send_password_reset_token(email: str) -> bool:
        try:
            user = User.objects.get(email=email.lower().strip())
        except User.DoesNotExist:
            return True # Never leak whether user exists

        token = str(uuid.uuid4())
        cache_key = f'password_reset:{token}'
        cache.set(cache_key, str(user.id), timeout=3600) # 1 hour

        send_mail(
            subject=f'{settings.APP_NAME} Password Reset',
            message=f'Use this reset token to change your password: {token}',
            from_email=settings.SUPPORT_EMAIL,
            recipient_list=[user.email],
            fail_silently=True
        )
        return True

    @staticmethod
    def reset_password_with_token(token: str, new_password: str) -> bool:
        cache_key = f'password_reset:{token}'
        user_id = cache.get(cache_key)
        if not user_id:
            return False
        try:
            user = User.objects.get(id=user_id)
            user.set_password(new_password)
            user.save(update_fields=['password'])
            cache.delete(cache_key)
            return True
        except User.DoesNotExist:
            return False
