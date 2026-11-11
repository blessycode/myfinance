import uuid
from decimal import Decimal
from django.db import models
from django.conf import settings
from django.utils import timezone

class PlanTier(models.TextChoices):
    FREE = 'free', 'Free Starter'
    PRO = 'pro', 'Pro Financial Suite'
    ENTERPRISE = 'enterprise', 'Enterprise / Family Office'

class SubscriptionStatus(models.TextChoices):
    ACTIVE = 'active', 'Active'
    TRIALING = 'trialing', 'Trialing'
    CANCELED = 'canceled', 'Canceled'
    EXPIRED = 'expired', 'Expired'

class SubscriptionPlan(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=80)
    tier = models.CharField(max_length=20, choices=PlanTier.choices, default=PlanTier.FREE, unique=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0.00'))
    currency = models.CharField(max_length=6, default='USD')
    billing_interval = models.CharField(max_length=20, default='month')
    features = models.JSONField(default=list)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'billing_plans'

    def __str__(self):
        return f"{self.name} ({self.tier})"

class UserSubscription(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='subscription')
    plan = models.ForeignKey(SubscriptionPlan, on_delete=models.PROTECT, related_name='user_subscriptions')
    status = models.CharField(max_length=20, choices=SubscriptionStatus.choices, default=SubscriptionStatus.ACTIVE)
    start_date = models.DateTimeField(default=timezone.now)
    expires_at = models.DateTimeField(null=True, blank=True)
    store_source = models.CharField(max_length=30, default='direct')
    store_transaction_id = models.CharField(max_length=150, blank=True)

    class Meta:
        db_table = 'user_subscriptions'

    def __str__(self):
        return f"{self.user.email} - {self.plan.name} ({self.status})"

    @property
    def is_pro_or_higher(self) -> bool:
        if self.status not in (SubscriptionStatus.ACTIVE, SubscriptionStatus.TRIALING):
            return False
        if self.expires_at and self.expires_at < timezone.now():
            return False
        return self.plan.tier in (PlanTier.PRO, PlanTier.ENTERPRISE)
