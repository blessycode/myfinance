from rest_framework import serializers
from .models import FinancialAccount

class FinancialAccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = FinancialAccount
        fields = [
            'id',
            'name',
            'account_type',
            'currency',
            'opening_balance',
            'current_balance',
            'institution_name',
            'description',
            'color',
            'icon',
            'is_active',
            'is_archived',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'current_balance', 'created_at', 'updated_at']

    def create(self, validated_data):
        user = self.context['request'].user
        opening = validated_data.get('opening_balance', 0)
        # On account creation, initial current balance equals opening balance
        account = FinancialAccount.objects.create(
            user=user,
            current_balance=opening,
            **validated_data
        )
        return account

class AccountBalanceSummarySerializer(serializers.Serializer):
    id = serializers.UUIDField()
    name = serializers.CharField()
    currency = serializers.CharField()
    current_balance = serializers.DecimalField(max_digits=18, decimal_places=2)
    converted_balance = serializers.DecimalField(max_digits=18, decimal_places=2)
    display_currency = serializers.CharField()
    last_updated = serializers.DateTimeField()
