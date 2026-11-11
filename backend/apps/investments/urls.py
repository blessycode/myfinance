from django.urls import path
from .views import InvestmentListCreateView, InvestmentDetailView

urlpatterns = [
    path('', InvestmentListCreateView.as_view(), name='investment-list-create'),
    path('<uuid:pk>/', InvestmentDetailView.as_view(), name='investment-detail'),
]
