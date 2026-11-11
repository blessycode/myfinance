from rest_framework import generics, views, permissions, status
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from .models import SubscriptionPlan, UserSubscription, PlanTier

class PlanListView(generics.ListAPIView):
    queryset = SubscriptionPlan.objects.filter(is_active=True)
    permission_classes = [permissions.AllowAny]
    pagination_class = None

    @extend_schema(summary="List commercial subscription tiers (Free, Pro, Enterprise)")
    def get(self, request, *args, **kwargs):
        # Auto-seed default plans if empty
        if not SubscriptionPlan.objects.exists():
            SubscriptionPlan.objects.create(
                name="Starter Free",
                tier=PlanTier.FREE,
                price=0.00,
                features=["Up to 5 accounts", "Basic analytics", "Standard budgeting"]
            )
            SubscriptionPlan.objects.create(
                name="Pro Finance Suite",
                tier=PlanTier.PRO,
                price=9.99,
                features=["Unlimited accounts", "Advanced analytics & trends", "PDF & Excel exports", "Multi-currency live ledger"]
            )
        return super().get(request, *args, **kwargs)

class UserSubscriptionView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(summary="Get current user commercial subscription & entitlement status")
    def get(self, request):
        sub, _ = UserSubscription.objects.get_or_create(
            user=request.user,
            defaults={
                'plan': SubscriptionPlan.objects.get_or_create(
                    tier=PlanTier.FREE,
                    defaults={'name': 'Starter Free', 'price': 0.00}
                )[0]
            }
        )
        return Response({
            'tier': sub.plan.tier,
            'plan_name': sub.plan.name,
            'is_pro': sub.is_pro_or_higher,
            'status': sub.status,
            'expires_at': sub.expires_at
        }, status=status.HTTP_200_OK)
