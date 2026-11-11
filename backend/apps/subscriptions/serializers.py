from django.utils import timezone
from rest_framework import serializers
from .models import Subscription
from apps.categories.serializers import CategorySerializer

class SubscriptionSerializer(serializers.ModelSerializer):
    category_details = CategorySerializer(source='category', read_only=True)
    days_until_due = serializers.SerializerMethodField()
    is_due_soon = serializers.SerializerMethodField()
    is_overdue = serializers.SerializerMethodField()

    class Meta:
        model = Subscription
        fields = [
            'id',
            'name',
            'merchant',
            'amount',
            'currency',
            'frequency',
            'next_due_date',
            'category',
            'category_details',
            'account',
            'remind_days_before',
            'icon',
            'color',
            'is_active',
            'days_until_due',
            'is_due_soon',
            'is_overdue',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']

    def get_days_until_due(self, obj) -> int:
        delta = obj.next_due_date - timezone.now().date()
        return delta.days

    def get_is_due_soon(self, obj) -> bool:
        days = self.get_days_until_due(obj)
        return 0 <= days <= obj.remind_days_before

    def get_is_overdue(self, obj) -> bool:
        return self.get_days_until_due(obj) < 0

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)
