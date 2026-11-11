from rest_framework import generics, permissions
from drf_spectacular.utils import extend_schema
from .models import Subscription
from .serializers import SubscriptionSerializer

class SubscriptionListCreateView(generics.ListCreateAPIView):
    serializer_class = SubscriptionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Subscription.objects.filter(user=self.request.user, is_active=True).select_related('category', 'account')

    @extend_schema(summary="List active subscriptions & recurring bills with due alert indicators")
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(summary="Create a new subscription or recurring bill")
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

class SubscriptionDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = SubscriptionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Subscription.objects.filter(user=self.request.user)
