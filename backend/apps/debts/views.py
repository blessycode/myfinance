from decimal import Decimal
from django.db import transaction as db_transaction
from rest_framework import generics, permissions, status, views
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from .models import Debt, DebtPayment
from .serializers import DebtSerializer, DebtPaymentCreateSerializer, DebtPaymentSerializer
from apps.transactions.models import TransactionType
from apps.transactions.services import TransactionLedgerService
from common.utilities.money import round_money

class DebtListCreateView(generics.ListCreateAPIView):
    serializer_class = DebtSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Debt.objects.filter(user=self.request.user)

    @extend_schema(summary="List all tracked debts and obligations")
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(summary="Record a new debt, loan, or credit obligation")
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

class DebtDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = DebtSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Debt.objects.filter(user=self.request.user)

class DebtPaymentView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        request=DebtPaymentCreateSerializer,
        responses={201: DebtPaymentSerializer},
        summary="Record a repayment against a debt (deducted atomically from funding account)"
    )
    @db_transaction.atomic
    def post(self, request, pk):
        try:
            debt = Debt.objects.get(pk=pk, user=request.user)
        except Debt.DoesNotExist:
            return Response({'detail': 'Debt record not found'}, status=status.HTTP_404_NOT_FOUND)

        serializer = DebtPaymentCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        account = data['account']
        if account.user != request.user:
            return Response({'detail': 'Unauthorized access to account.'}, status=status.HTTP_403_FORBIDDEN)

        amount = round_money(data['amount'])

        # Post transaction in ledger
        trx = TransactionLedgerService.post_transaction(
            user=request.user,
            account=account,
            transaction_type=TransactionType.DEBT_REPAYMENT,
            amount=amount,
            currency=debt.currency,
            description=f"Repayment towards {debt.name} ({debt.counterparty})",
            transaction_date=data['payment_date'],
            notes=data.get('notes', '')
        )

        # Update debt balance
        debt.current_balance = round_money(max(Decimal('0.00'), debt.current_balance - amount))
        if debt.current_balance == Decimal('0.00'):
            debt.is_settled = True
        debt.save(update_fields=['current_balance', 'is_settled'])

        # Log payment
        payment = DebtPayment.objects.create(
            debt=debt,
            account=account,
            transaction=trx,
            amount=amount,
            currency=debt.currency,
            payment_date=data['payment_date'],
            notes=data.get('notes', '')
        )

        return Response(DebtPaymentSerializer(payment).data, status=status.HTTP_201_CREATED)
