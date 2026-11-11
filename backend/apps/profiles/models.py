import uuid
from django.db import models
from django.conf import settings

def default_notification_prefs():
    return {
        'budget_alerts': True,
        'bill_reminders': True,
        'weekly_summary': True,
        'savings_milestones': True,
        'security_alerts': True,
    }

def default_security_prefs():
    return {
        'biometric_enabled': False,
        'require_pin_on_launch': False,
        'hide_balances_on_launch': False,
    }

class Profile(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='profile')
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True)
    country = models.CharField(max_length=100, default='United States')
    preferred_currency = models.CharField(max_length=6, default='USD')
    timezone = models.CharField(max_length=50, default='UTC')
    language = models.CharField(max_length=10, default='en')
    date_of_birth = models.DateField(null=True, blank=True)

    notification_preferences = models.JSONField(default=default_notification_prefs)
    security_preferences = models.JSONField(default=default_security_prefs)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'user_profiles'
        verbose_name = 'User Profile'
        verbose_name_plural = 'User Profiles'

    def __str__(self):
        return f"{self.user.email} Profile"
