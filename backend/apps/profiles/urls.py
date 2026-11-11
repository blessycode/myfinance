from django.urls import path
from .views import ProfileView, SettingsView

urlpatterns = [
    path('profile/', ProfileView.as_view(), name='profile-detail'),
    path('settings/', SettingsView.as_view(), name='settings-detail'),
]
