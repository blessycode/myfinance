from django.urls import path
from .views import (
    TransactionListCreateView,
    TransactionDetailView,
    TransferView,
    ReverseTransactionView,
    TransactionSummaryView,
)

urlpatterns = [
    path('', TransactionListCreateView.as_view(), name='transaction-list-create'),
    path('transfer/', TransferView.as_view(), name='transaction-transfer'),
    path('summary/', TransactionSummaryView.as_view(), name='transaction-summary'),
    path('<uuid:pk>/', TransactionDetailView.as_view(), name='transaction-detail'),
    path('<uuid:pk>/reverse/', ReverseTransactionView.as_view(), name='transaction-reverse'),
]
