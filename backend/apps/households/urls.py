from django.urls import path
from .views import HouseholdListCreateView, HouseholdDetailView

urlpatterns = [
    path('', HouseholdListCreateView.as_view(), name='household-list-create'),
    path('<uuid:pk>/', HouseholdDetailView.as_view(), name='household-detail'),
]
