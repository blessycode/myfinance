from rest_framework import serializers
from .models import Transaction, TransactionType, PaymentMethod
from apps.financial_accounts.models import FinancialAccount
from apps.categories.models import Category
from apps.categories.serializers import CategorySerializer

class TransactionSerializer(serializers.ModelSerializer):
    category_details = CategorySerializer(source='category', read_only=True)
    account_name = serializers.CharField(source='account.name', read_only=True)
    to_account_name = serializers.CharField(source='to_account.name', read_only=True)

    class Meta:
        model = Transaction
        fields = [
            'id',
            'account',
            'account_name',
            'to_account',
            'to_account_name',
            'transaction_type',
            'category',
            'category_details',
            'amount',
            'currency',
            'description',
            'merchant',
            'transaction_date',
            'payment_method',
            'notes',
            'receipt_attachment',
            'is_reversed',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'is_reversed', 'created_at', 'updated_at']

class TransactionCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = [
            'account',
            'transaction_type',
            'category',
            'amount',
            'currency',
            'description',
            'merchant',
            'transaction_date',
            'payment_method',
            'notes',
            'receipt_attachment',
            'idempotency_key',
        ]

    def validate_amount(self, value):
        if value <= 0:
            raise serializers.ValidationError('Amount must be strictly greater than 0.00.')
        return value

class TransferCreateSerializer(serializers.Serializer):
    from_account = serializers.PrimaryKeyRelatedField(queryset=FinancialAccount.objects.all())
    to_account = serializers.PrimaryKeyRelatedField(queryset=FinancialAccount.objects.all())
    amount = serializers.DecimalField(max_digits=18, decimal_places=2)
    description = serializers.CharField(required=False, default='')
    transaction_date = serializers.DateField()
    idempotency_key = serializers.CharField(required=False, allow_blank=True)

    def validate(self, attrs):
        if attrs['from_account'] == attrs['to_account']:
            raise serializers.ValidationError('Source and destination accounts must be distinct.')
        if attrs['amount'] <= 0:
            raise serializers.ValidationError('Transfer amount must be positive.')
        return attrs

class TransactionSummarySerializer(serializers.Serializer):
    total_income = serializers.DecimalField(max_digits=18, decimal_places=2)
    total_expense = serializers.DecimalField(max_digits=18, decimal_places=2)
    net_savings = serializers.DecimalField(max_digits=18, decimal_places=2)
    currency = serializers.CharField()
    period = serializers.CharField()
