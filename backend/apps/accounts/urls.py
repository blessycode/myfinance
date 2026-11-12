from django.urls import path
from .views import (
    RegisterView,
    LoginView,
    GoogleLoginView,
    TokenRefreshView,
    LogoutView,
    ForgotPasswordView,
    ResetPasswordView,
    VerifyEmailView,
    CurrentUserView,
)

urlpatterns = [
    path('register/', RegisterView.as_view(), name='auth-register'),
    path('login/', LoginView.as_view(), name='auth-login'),
    path('google/', GoogleLoginView.as_view(), name='auth-google'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('logout/', LogoutView.as_view(), name='auth-logout'),
    path('forgot-password/', ForgotPasswordView.as_view(), name='auth-forgot-password'),
    path('reset-password/', ResetPasswordView.as_view(), name='auth-reset-password'),
    path('verify-email/', VerifyEmailView.as_view(), name='auth-verify-email'),
    path('me/', CurrentUserView.as_view(), name='auth-me'),
]
