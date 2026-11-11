from rest_framework import views, permissions, status
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiParameter
from .services import AnalyticsService

class DashboardAnalyticsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(summary="Get home dashboard executive metrics, converted balance, and smart insights")
    def get(self, request):
        data = AnalyticsService.get_dashboard_summary(request.user)
        return Response(data, status=status.HTTP_200_OK)

class SpendingBreakdownView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        summary="Get category-by-category spending breakdown for interactive donut chart",
        parameters=[OpenApiParameter('days', int, description="Lookback window in days (default 30)")]
    )
    def get(self, request):
        days = int(request.query_params.get('days', 30))
        data = AnalyticsService.get_spending_breakdown(request.user, days=days)
        return Response(data, status=status.HTTP_200_OK)

class SpendingTrendsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        summary="Get multi-month income versus expense bar trends",
        parameters=[OpenApiParameter('months', int, description="Number of historical months (default 6)")]
    )
    def get(self, request):
        months = int(request.query_params.get('months', 6))
        data = AnalyticsService.get_spending_trends(request.user, months=months)
        return Response(data, status=status.HTTP_200_OK)

class TopCategoriesView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(summary="Get top spending categories")
    def get(self, request):
        data = AnalyticsService.get_spending_breakdown(request.user, days=30)[:5]
        return Response(data, status=status.HTTP_200_OK)
