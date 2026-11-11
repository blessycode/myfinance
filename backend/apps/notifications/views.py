from rest_framework import generics, permissions, status, views
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from .models import Notification
from .serializers import NotificationSerializer

class NotificationListView(generics.ListAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)

    @extend_schema(summary="List in-app alerts and notifications")
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

class NotificationMarkReadView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(summary="Mark an individual notification as read")
    def patch(self, request, pk):
        try:
            notif = Notification.objects.get(pk=pk, user=request.user)
            notif.is_read = True
            notif.save(update_fields=['is_read'])
            return Response(NotificationSerializer(notif).data, status=status.HTTP_200_OK)
        except Notification.DoesNotExist:
            return Response({'detail': 'Notification not found'}, status=status.HTTP_404_NOT_FOUND)

class NotificationReadAllView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(summary="Mark all unread notifications as read")
    def post(self, request):
        updated = Notification.objects.filter(user=request.user, is_read=False).update(is_read=True)
        return Response({'detail': f'Marked {updated} notifications as read'}, status=status.HTTP_200_OK)
