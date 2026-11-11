from rest_framework import generics, permissions
from drf_spectacular.utils import extend_schema
from .models import Investment
from .serializers import InvestmentSerializer

class InvestmentListCreateView(generics.ListCreateAPIView):
    serializer_class = InvestmentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Investment.objects.filter(user=self.request.user)

    @extend_schema(summary="List all investment portfolio holdings")
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(summary="Add an investment holding")
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

class InvestmentDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = InvestmentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Investment.objects.filter(user=self.request.user)
