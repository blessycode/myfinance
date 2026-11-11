from django.urls import path
from .views import (
    DashboardAnalyticsView,
    SpendingBreakdownView,
    SpendingTrendsView,
    TopCategoriesView,
)

urlpatterns = [
    path('dashboard/', DashboardAnalyticsView.as_view(), name='analytics-dashboard'),
    path('spending-breakdown/', SpendingBreakdownView.as_view(), name='analytics-spending-breakdown'),
    path('spending-trends/', SpendingTrendsView.as_view(), name='analytics-spending-trends'),
    path('top-categories/', TopCategoriesView.as_view(), name='analytics-top-categories'),
]
