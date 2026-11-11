from rest_framework import serializers
from .models import Debt, DebtPayment
from apps.financial_accounts.models import FinancialAccount

class DebtSerializer(serializers.ModelSerializer):
    class Meta:
        model = Debt
        fields = [
            'id',
            'name',
            'debt_type',
            'counterparty',
            'original_amount',
            'current_balance',
            'currency',
            'interest_rate',
            'due_date',
            'is_settled',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        if 'current_balance' not in validated_data:
            validated_data['current_balance'] = validated_data['original_amount']
        return super().create(validated_data)

class DebtPaymentCreateSerializer(serializers.Serializer):
    account = serializers.PrimaryKeyRelatedField(queryset=FinancialAccount.objects.all())
    amount = serializers.DecimalField(max_digits=18, decimal_places=2)
    payment_date = serializers.DateField()
    notes = serializers.CharField(required=False, allow_blank=True, default='')

class DebtPaymentSerializer(serializers.ModelSerializer):
    account_name = serializers.CharField(source='account.name', read_only=True)

    class Meta:
        model = DebtPayment
        fields = ['id', 'account', 'account_name', 'amount', 'currency', 'payment_date', 'notes', 'created_at']
