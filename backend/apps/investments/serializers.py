from rest_framework import serializers
from .models import Investment

class InvestmentSerializer(serializers.ModelSerializer):
    total_invested = serializers.ReadOnlyField()
    current_valuation = serializers.ReadOnlyField()
    unrealized_pl = serializers.ReadOnlyField()
    percentage_return = serializers.ReadOnlyField()

    class Meta:
        model = Investment
        fields = [
            'id',
            'name',
            'symbol',
            'asset_type',
            'units',
            'purchase_price',
            'current_price',
            'currency',
            'notes',
            'total_invested',
            'current_valuation',
            'unrealized_pl',
            'percentage_return',
            'last_valuation_date',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)
