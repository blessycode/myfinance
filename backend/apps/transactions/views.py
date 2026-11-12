from decimal import Decimal
from django.db.models import Sum, Q
from django.utils import timezone
from rest_framework import generics, views, permissions, status, filters
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from drf_spectacular.utils import extend_schema, OpenApiParameter

from .models import Transaction, TransactionType
from .serializers import (
    TransactionSerializer,
    TransactionCreateSerializer,
    TransferCreateSerializer,
    TransactionSummarySerializer,
)
from .services import TransactionLedgerService
from apps.exchange_rates.services import CurrencyConversionService
from apps.notifications.models import Notification, NotificationType

class TransactionListCreateView(generics.ListCreateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['transaction_type', 'account', 'category', 'currency', 'is_reversed']
    search_fields = ['description', 'merchant', 'notes']
    ordering_fields = ['transaction_date', 'amount', 'created_at']
    ordering = ['-transaction_date', '-created_at']

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return TransactionCreateSerializer
        return TransactionSerializer

    def get_queryset(self):
        qs = Transaction.objects.filter(user=self.request.user).select_related('account', 'to_account', 'category')
        start_date = self.request.query_params.get('start_date')
        end_date = self.request.query_params.get('end_date')
        if start_date:
            qs = qs.filter(transaction_date__gte=start_date)
        if end_date:
            qs = qs.filter(transaction_date__lte=end_date)
        return qs

    @extend_schema(
        summary="List transactions with multi-currency filtering, searching, and pagination",
        parameters=[
            OpenApiParameter('start_date', str, description="Filter from YYYY-MM-DD"),
            OpenApiParameter('end_date', str, description="Filter to YYYY-MM-DD"),
        ]
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(summary="Record an income, expense, debt repayment, or savings transaction")
    def post(self, request, *args, **kwargs):
        serializer = TransactionCreateSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        trx = TransactionLedgerService.post_transaction(
            user=request.user,
            account=data['account'],
            transaction_type=data['transaction_type'],
            amount=data['amount'],
            currency=data.get('currency', data['account'].currency),
            description=data['description'],
            transaction_date=data['transaction_date'],
            category=data.get('category'),
            merchant=data.get('merchant', ''),
            payment_method=data.get('payment_method', 'bank_transfer'),
            notes=data.get('notes', ''),
            receipt_attachment=data.get('receipt_attachment'),
            idempotency_key=data.get('idempotency_key'),
        )

        if trx.transaction_type != TransactionType.TRANSFER:
            Notification.objects.get_or_create(
                user=request.user,
                title='Transaction recorded',
                data={'transaction_id': str(trx.pk)},
                defaults={
                    'body': f"{trx.get_transaction_type_display()} of {trx.currency} {trx.amount} was added to {trx.account.name}.",
                    'notification_type': NotificationType.SYSTEM,
                },
            )

        return Response(TransactionSerializer(trx).data, status=status.HTTP_201_CREATED)

class TransactionDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = TransactionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Transaction.objects.filter(user=self.request.user)

    def destroy(self, request, *args, **kwargs):
        trx = self.get_object()
        # Reversing instead of raw deletion guarantees auditable ledger integrity
        TransactionLedgerService.reverse_transaction(request.user, trx, reason="User deletion")
        return Response({'detail': 'Transaction reversed successfully.'}, status=status.HTTP_200_OK)

class TransferView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        request=TransferCreateSerializer,
        responses={201: TransactionSerializer},
        summary="Transfer funds between two accounts (never counted as income/expense)"
    )
    def post(self, request):
        serializer = TransferCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        trx = TransactionLedgerService.post_transfer(
            user=request.user,
            from_account=data['from_account'],
            to_account=data['to_account'],
            amount=data['amount'],
            description=data.get('description', ''),
            transaction_date=data['transaction_date'],
            idempotency_key=data.get('idempotency_key'),
        )

        return Response(TransactionSerializer(trx).data, status=status.HTTP_201_CREATED)

class ReverseTransactionView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(summary="Reverse a posted financial transaction atomically")
    def post(self, request, pk):
        try:
            trx = Transaction.objects.get(pk=pk, user=request.user)
        except Transaction.DoesNotExist:
            return Response({'detail': 'Transaction not found'}, status=status.HTTP_404_NOT_FOUND)

        reason = request.data.get('reason', 'User initiated reversal')
        reversal = TransactionLedgerService.reverse_transaction(request.user, trx, reason=reason)
        return Response({
            'detail': 'Transaction reversed successfully.',
            'reversal': TransactionSerializer(reversal).data
        }, status=status.HTTP_200_OK)

class TransactionSummaryView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        responses={200: TransactionSummarySerializer},
        summary="Get monthly summary of income and expenses normalized into preferred display currency"
    )
    def get(self, request):
        pref_currency = request.user.profile.preferred_currency if hasattr(request.user, 'profile') else 'USD'
        now = timezone.now()
        month = int(request.query_params.get('month', now.month))
        year = int(request.query_params.get('year', now.year))

        trxs = Transaction.objects.filter(
            user=request.user,
            transaction_date__year=year,
            transaction_date__month=month,
            is_reversed=False
        ).exclude(transaction_type=TransactionType.TRANSFER)

        total_income = Decimal('0.00')
        total_expense = Decimal('0.00')

        for t in trxs:
            converted, _ = CurrencyConversionService.convert(t.amount, t.currency, pref_currency)
            if t.transaction_type == TransactionType.INCOME:
                total_income += converted
            elif t.transaction_type == TransactionType.EXPENSE:
                total_expense += converted

        net_savings = total_income - total_expense

        data = {
            'total_income': total_income,
            'total_expense': total_expense,
            'net_savings': net_savings,
            'currency': pref_currency,
            'period': f"{year}-{month:02d}"
        }
        return Response(data, status=status.HTTP_200_OK)
