from django.urls import path
from .views import BudgetListCreateView, BudgetDetailView, BudgetProgressView

urlpatterns = [
    path('', BudgetListCreateView.as_view(), name='budget-list-create'),
    path('<uuid:pk>/', BudgetDetailView.as_view(), name='budget-detail'),
    path('<uuid:pk>/progress/', BudgetProgressView.as_view(), name='budget-progress'),
]
