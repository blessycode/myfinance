from rest_framework import serializers
from .models import SubscriptionPlan, UserSubscription

class SubscriptionPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = SubscriptionPlan
        fields = ['id', 'name', 'tier', 'price', 'currency', 'billing_interval', 'features', 'is_active']

class UserSubscriptionSerializer(serializers.ModelSerializer):
    plan_name = serializers.CharField(source='plan.name', read_only=True)
    tier = serializers.CharField(source='plan.tier', read_only=True)
    is_pro = serializers.BooleanField(source='is_pro_or_higher', read_only=True)

    class Meta:
        model = UserSubscription
        fields = ['id', 'plan', 'plan_name', 'tier', 'status', 'start_date', 'expires_at', 'store_source', 'is_pro']
        read_only_fields = ['id', 'status', 'start_date', 'expires_at']
