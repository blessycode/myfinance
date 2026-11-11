from rest_framework import views, permissions, status
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from .serializers import ProfileSerializer, SettingsSerializer

class ProfileView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(responses={200: ProfileSerializer}, summary="Get authenticated user's profile")
    def get(self, request):
        profile = request.user.profile
        serializer = ProfileSerializer(profile)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @extend_schema(request=ProfileSerializer, responses={200: ProfileSerializer}, summary="Update profile")
    def patch(self, request):
        profile = request.user.profile
        serializer = ProfileSerializer(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)

class SettingsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(responses={200: SettingsSerializer}, summary="Get user financial & app settings")
    def get(self, request):
        profile = request.user.profile
        serializer = SettingsSerializer(profile)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @extend_schema(request=SettingsSerializer, responses={200: SettingsSerializer}, summary="Update user settings")
    def patch(self, request):
        profile = request.user.profile
        serializer = SettingsSerializer(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
