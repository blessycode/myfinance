from decimal import Decimal
from django.utils import timezone
from rest_framework import serializers
from .models import SavingsGoal, GoalContribution
from apps.financial_accounts.models import FinancialAccount

class GoalContributionSerializer(serializers.ModelSerializer):
    account_name = serializers.CharField(source='from_account.name', read_only=True)

    class Meta:
        model = GoalContribution
        fields = ['id', 'from_account', 'account_name', 'amount', 'currency', 'note', 'created_at']
        read_only_fields = ['id', 'created_at']

class SavingsGoalSerializer(serializers.ModelSerializer):
    percentage = serializers.SerializerMethodField()
    remaining = serializers.SerializerMethodField()
    days_remaining = serializers.SerializerMethodField()

    class Meta:
        model = SavingsGoal
        fields = [
            'id',
            'name',
            'emoji',
            'target_amount',
            'current_amount',
            'currency',
            'target_date',
            'description',
            'color',
            'is_completed',
            'percentage',
            'remaining',
            'days_remaining',
            'created_at',
        ]
        read_only_fields = ['id', 'current_amount', 'is_completed', 'created_at']

    def get_percentage(self, obj) -> float:
        if obj.target_amount <= Decimal('0.00'):
            return 0.0
        return float(min(Decimal('1.00'), obj.current_amount / obj.target_amount))

    def get_remaining(self, obj) -> Decimal:
        return max(Decimal('0.00'), obj.target_amount - obj.current_amount)

    def get_days_remaining(self, obj) -> int:
        delta = obj.target_date - timezone.now().date()
        return max(0, delta.days)

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)

class GoalContributionCreateSerializer(serializers.Serializer):
    from_account = serializers.PrimaryKeyRelatedField(queryset=FinancialAccount.objects.all())
    amount = serializers.DecimalField(max_digits=18, decimal_places=2)
    note = serializers.CharField(required=False, allow_blank=True, default='')

    def validate_amount(self, value):
        if value <= Decimal('0.00'):
            raise serializers.ValidationError('Contribution amount must be positive.')
        return value
