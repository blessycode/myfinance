from rest_framework import generics, permissions, status, views
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from .models import SavingsGoal, GoalContribution
from .serializers import (
    SavingsGoalSerializer,
    GoalContributionSerializer,
    GoalContributionCreateSerializer
)
from .services import GoalService

class GoalListCreateView(generics.ListCreateAPIView):
    serializer_class = SavingsGoalSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return SavingsGoal.objects.filter(user=self.request.user).order_by('target_date')

    @extend_schema(summary="List all savings goals for authenticated user")
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(summary="Create a new savings milestone goal")
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

class GoalDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = SavingsGoalSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return SavingsGoal.objects.filter(user=self.request.user)

class GoalContributionView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        request=GoalContributionCreateSerializer,
        responses={201: GoalContributionSerializer},
        summary="Contribute funds to a savings goal (deducted atomically from chosen account)"
    )
    def post(self, request, pk):
        try:
            goal = SavingsGoal.objects.get(pk=pk, user=request.user)
        except SavingsGoal.DoesNotExist:
            return Response({'detail': 'Savings goal not found'}, status=status.HTTP_404_NOT_FOUND)

        serializer = GoalContributionCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        contrib = GoalService.record_contribution(
            user=request.user,
            goal=goal,
            from_account=serializer.validated_data['from_account'],
            amount=serializer.validated_data['amount'],
            note=serializer.validated_data.get('note', '')
        )

        return Response(GoalContributionSerializer(contrib).data, status=status.HTTP_201_CREATED)

class GoalHistoryView(generics.ListAPIView):
    serializer_class = GoalContributionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        goal_id = self.kwargs['pk']
        return GoalContribution.objects.filter(goal_id=goal_id, goal__user=self.request.user).order_by('-created_at')

    @extend_schema(summary="Get deposit and contribution history for a savings goal")
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
