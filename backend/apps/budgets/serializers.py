from decimal import Decimal
from rest_framework import serializers
from .models import Budget
from apps.categories.serializers import CategorySerializer

class BudgetSerializer(serializers.ModelSerializer):
    category_details = CategorySerializer(source='category', read_only=True)
    spent = serializers.SerializerMethodField()
    remaining = serializers.SerializerMethodField()
    percentage = serializers.SerializerMethodField()
    is_exceeded = serializers.SerializerMethodField()
    is_warning = serializers.SerializerMethodField()

    class Meta:
        model = Budget
        fields = [
            'id',
            'name',
            'category',
            'category_details',
            'amount',
            'currency',
            'period',
            'start_date',
            'end_date',
            'alert_threshold',
            'color',
            'is_active',
            'spent',
            'remaining',
            'percentage',
            'is_exceeded',
            'is_warning',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']

    def get_spent(self, obj) -> Decimal:
        return obj.calculate_spent()

    def get_remaining(self, obj) -> Decimal:
        spent = self.get_spent(obj)
        return max(Decimal('0.00'), obj.amount - spent)

    def get_percentage(self, obj) -> float:
        if obj.amount <= Decimal('0.00'):
            return 0.0
        spent = self.get_spent(obj)
        return float(min(Decimal('1.00'), spent / obj.amount))

    def get_is_exceeded(self, obj) -> bool:
        return self.get_spent(obj) > obj.amount

    def get_is_warning(self, obj) -> bool:
        percentage = self.get_percentage(obj)
        return percentage >= float(obj.alert_threshold)

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)
