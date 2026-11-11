from rest_framework import generics, permissions, status, views
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from .models import Budget
from .serializers import BudgetSerializer

class BudgetListCreateView(generics.ListCreateAPIView):
    serializer_class = BudgetSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Budget.objects.filter(user=self.request.user, is_active=True).select_related('category')

    @extend_schema(summary="List active budgets with live spending calculations")
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(summary="Create a new budget envelope")
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

class BudgetDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = BudgetSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Budget.objects.filter(user=self.request.user)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.is_active = False
        instance.save(update_fields=['is_active'])
        return Response({'detail': 'Budget archived successfully.'}, status=status.HTTP_200_OK)

class BudgetProgressView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(summary="Get detailed progress and alert indicators for a budget")
    def get(self, request, pk):
        try:
            budget = Budget.objects.get(pk=pk, user=request.user)
        except Budget.DoesNotExist:
            return Response({'detail': 'Budget not found'}, status=status.HTTP_404_NOT_FOUND)

        serializer = BudgetSerializer(budget, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)
