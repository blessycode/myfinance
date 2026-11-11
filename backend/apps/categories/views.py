from django.db.models import Q
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from .models import Category
from .serializers import CategorySerializer
from .services import CategoryService

class CategoryListCreateView(generics.ListCreateAPIView):
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

    def get_queryset(self):
        # Auto-seed system categories if none exist yet
        if not Category.objects.filter(is_system=True).exists():
            CategoryService.seed_system_categories()

        cat_type = self.request.query_params.get('type')
        qs = Category.objects.filter(Q(user=self.request.user) | Q(is_system=True))
        if cat_type:
            qs = qs.filter(type=cat_type)
        return qs.order_by('type', 'name')

    @extend_schema(summary="List default system and user-created custom categories")
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(summary="Create a custom category for the authenticated user")
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

class CategoryDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Users can only modify/delete their own custom categories (not system categories)
        return Category.objects.filter(user=self.request.user, is_system=False)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        self.perform_destroy(instance)
        return Response({'detail': 'Custom category removed successfully'}, status=status.HTTP_200_OK)
