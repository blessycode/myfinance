from rest_framework import status, views, permissions
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenRefreshView as BaseTokenRefreshView
from drf_spectacular.utils import extend_schema, OpenApiResponse
from django.conf import settings
from google.auth.exceptions import GoogleAuthError
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token

from .models import User
from .serializers import (
    UserSerializer,
    RegisterSerializer,
    LoginSerializer,
    GoogleLoginSerializer,
    PasswordResetRequestSerializer,
    PasswordResetConfirmSerializer,
    VerifyEmailSerializer,
)
from .services import AccountAuthService

class RegisterView(views.APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        request=RegisterSerializer,
        responses={201: OpenApiResponse(description="User registered successfully")},
        summary="Register a new user account"
    )
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        # Generate tokens
        tokens = AccountAuthService.generate_tokens_for_user(user)

        # Trigger verification email
        AccountAuthService.send_verification_token(user)

        return Response({
            'detail': 'Account registered successfully',
            'tokens': tokens,
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)

class LoginView(views.APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        request=LoginSerializer,
        responses={200: OpenApiResponse(description="Authentication tokens returned")},
        summary="Authenticate user and issue JWT"
    )
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']

        tokens = AccountAuthService.generate_tokens_for_user(user)
        return Response({
            'detail': 'Login successful',
            'tokens': tokens,
            'user': UserSerializer(user).data
        }, status=status.HTTP_200_OK)

class GoogleLoginView(views.APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        request=GoogleLoginSerializer,
        responses={200: OpenApiResponse(description="Google account authenticated and API tokens returned")},
        summary="Verify a Google ID token and issue JIREH API tokens",
    )
    def post(self, request):
        if not settings.GOOGLE_CLIENT_ID:
            return Response(
                {'detail': 'Google sign-in is not configured on the server yet.'},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        serializer = GoogleLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        raw_token = serializer.validated_data['id_token']

        try:
            claims = id_token.verify_oauth2_token(
                raw_token,
                google_requests.Request(),
                audience=settings.GOOGLE_CLIENT_ID,
            )
        except (GoogleAuthError, ValueError):
            return Response({'detail': 'Google could not verify this sign-in. Please try again.'}, status=status.HTTP_401_UNAUTHORIZED)

        email = (claims.get('email') or '').strip().lower()
        if not email or claims.get('email_verified') is not True:
            return Response({'detail': 'Your Google account must have a verified email address.'}, status=status.HTTP_401_UNAUTHORIZED)

        given_name = (claims.get('given_name') or '').strip()
        family_name = (claims.get('family_name') or '').strip()
        user, created = User.objects.get_or_create(
            email=email,
            defaults={
                'first_name': given_name,
                'last_name': family_name,
                'is_verified': True,
            },
        )
        if not user.is_active:
            return Response({'detail': 'This account is disabled.'}, status=status.HTTP_403_FORBIDDEN)

        changed_fields = []
        if not user.is_verified:
            user.is_verified = True
            changed_fields.append('is_verified')
        if not user.first_name and given_name:
            user.first_name = given_name
            changed_fields.append('first_name')
        if not user.last_name and family_name:
            user.last_name = family_name
            changed_fields.append('last_name')
        if changed_fields:
            user.save(update_fields=changed_fields)

        tokens = AccountAuthService.generate_tokens_for_user(user)
        return Response({
            'detail': 'Google sign-in successful',
            'tokens': tokens,
            'user': UserSerializer(user).data,
            'created': created,
        }, status=status.HTTP_200_OK)

class TokenRefreshView(BaseTokenRefreshView):
    @extend_schema(summary="Refresh expired JWT access token")
    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        return response

class LogoutView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(summary="Revoke refresh token and logout")
    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            if refresh_token:
                token = RefreshToken(refresh_token)
                token.blacklist()
            return Response({'detail': 'Logged out successfully'}, status=status.HTTP_200_OK)
        except Exception:
            return Response({'detail': 'Invalid or expired token'}, status=status.HTTP_400_BAD_REQUEST)

class ForgotPasswordView(views.APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(request=PasswordResetRequestSerializer, summary="Request password reset token")
    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        AccountAuthService.send_password_reset_token(serializer.validated_data['email'])
        return Response({
            'detail': 'If the email exists, a password reset token has been dispatched.'
        }, status=status.HTTP_200_OK)

class ResetPasswordView(views.APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(request=PasswordResetConfirmSerializer, summary="Confirm password reset")
    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        success = AccountAuthService.reset_password_with_token(
            token=serializer.validated_data['token'],
            new_password=serializer.validated_data['new_password']
        )
        if not success:
            return Response({'detail': 'Invalid or expired reset token'}, status=status.HTTP_400_BAD_REQUEST)
        return Response({'detail': 'Password reset successfully'}, status=status.HTTP_200_OK)

class VerifyEmailView(views.APIView):
    permission_classes = [permissions.AllowAny]

    @extend_schema(request=VerifyEmailSerializer, summary="Verify user email address")
    def post(self, request):
        serializer = VerifyEmailSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        success = AccountAuthService.verify_email_token(serializer.validated_data['token'])
        if not success:
            return Response({'detail': 'Invalid or expired verification token'}, status=status.HTTP_400_BAD_REQUEST)
        return Response({'detail': 'Email verified successfully'}, status=status.HTTP_200_OK)

class CurrentUserView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(responses={200: UserSerializer}, summary="Get or update authenticated user")
    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def patch(self, request):
        serializer = UserSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
