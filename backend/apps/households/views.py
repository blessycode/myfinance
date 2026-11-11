from rest_framework import generics, permissions
from drf_spectacular.utils import extend_schema
from .models import Household
from .serializers import HouseholdSerializer

class HouseholdListCreateView(generics.ListCreateAPIView):
    serializer_class = HouseholdSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Household.objects.filter(members__user=self.request.user).distinct()

    @extend_schema(summary="List households and shared financial workspaces")
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(summary="Create a new household workspace")
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

class HouseholdDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = HouseholdSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Household.objects.filter(members__user=self.request.user).distinct()
