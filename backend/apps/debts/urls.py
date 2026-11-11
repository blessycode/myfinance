from django.urls import path
from .views import DebtListCreateView, DebtDetailView, DebtPaymentView

urlpatterns = [
    path('', DebtListCreateView.as_view(), name='debt-list-create'),
    path('<uuid:pk>/', DebtDetailView.as_view(), name='debt-detail'),
    path('<uuid:pk>/payments/', DebtPaymentView.as_view(), name='debt-payments'),
]
