from rest_framework import generics, permissions, status
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from .models import FinancialAccount
from .serializers import FinancialAccountSerializer, AccountBalanceSummarySerializer
from apps.exchange_rates.services import CurrencyConversionService

class AccountListCreateView(generics.ListCreateAPIView):
    serializer_class = FinancialAccountSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        qs = FinancialAccount.objects.filter(user=self.request.user)
        include_archived = self.request.query_params.get('include_archived', 'false').lower() == 'true'
        if not include_archived:
            qs = qs.filter(is_archived=False)
        return qs.order_by('-created_at')

    @extend_schema(summary="List all financial accounts for authenticated user")
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(summary="Create a new financial account")
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

class AccountDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = FinancialAccountSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return FinancialAccount.objects.filter(user=self.request.user)

    def destroy(self, request, *args, **kwargs):
        account = self.get_object()
        # Soft-delete / archive if financial transactions exist
        if hasattr(account, 'transactions') and account.transactions.exists():
            account.is_archived = True
            account.is_active = False
            account.save(update_fields=['is_archived', 'is_active'])
            return Response({
                'detail': 'Account contains transaction history and has been archived rather than permanently deleted.'
            }, status=status.HTTP_200_OK)

        self.perform_destroy(account)
        return Response({'detail': 'Account deleted successfully'}, status=status.HTTP_200_OK)

class AccountBalanceView(generics.RetrieveAPIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(responses={200: AccountBalanceSummarySerializer}, summary="Get account balance with live converted valuation")
    def get(self, request, pk):
        try:
            account = FinancialAccount.objects.get(pk=pk, user=request.user)
        except FinancialAccount.DoesNotExist:
            return Response({'detail': 'Account not found'}, status=status.HTTP_404_NOT_FOUND)

        pref_currency = request.user.profile.preferred_currency if hasattr(request.user, 'profile') else 'USD'
        converted_val, _ = CurrencyConversionService.convert(account.current_balance, account.currency, pref_currency)

        data = {
            'id': account.id,
            'name': account.name,
            'currency': account.currency,
            'current_balance': account.current_balance,
            'converted_balance': converted_val,
            'display_currency': pref_currency,
            'last_updated': account.updated_at
        }
        return Response(data, status=status.HTTP_200_OK)
