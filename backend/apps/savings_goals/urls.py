from django.urls import path
from .views import (
    GoalListCreateView,
    GoalDetailView,
    GoalContributionView,
    GoalHistoryView,
)

urlpatterns = [
    path('', GoalListCreateView.as_view(), name='goal-list-create'),
    path('<uuid:pk>/', GoalDetailView.as_view(), name='goal-detail'),
    path('<uuid:pk>/contributions/', GoalContributionView.as_view(), name='goal-contribute'),
    path('<uuid:pk>/history/', GoalHistoryView.as_view(), name='goal-history'),
]
