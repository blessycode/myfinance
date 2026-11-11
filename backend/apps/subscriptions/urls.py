from django.urls import path
from .views import SubscriptionListCreateView, SubscriptionDetailView

urlpatterns = [
    path('', SubscriptionListCreateView.as_view(), name='subscription-list-create'),
    path('<uuid:pk>/', SubscriptionDetailView.as_view(), name='subscription-detail'),
]
