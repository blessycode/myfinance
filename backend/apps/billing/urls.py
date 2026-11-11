from django.urls import path
from .views import PlanListView, UserSubscriptionView

urlpatterns = [
    path('plans/', PlanListView.as_view(), name='billing-plans'),
    path('status/', UserSubscriptionView.as_view(), name='billing-status'),
]
