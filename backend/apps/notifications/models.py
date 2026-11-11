import uuid
from django.db import models
from django.conf import settings

class NotificationType(models.TextChoices):
    BUDGET_ALERT = 'budget_alert', 'Budget Alert'
    BILL_REMINDER = 'bill_reminder', 'Bill Reminder'
    GOAL_MILESTONE = 'goal_milestone', 'Savings Milestone'
    SECURITY_ALERT = 'security_alert', 'Security Alert'
    SYSTEM = 'system', 'System Notice'

class Notification(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=150)
    body = models.TextField()
    notification_type = models.CharField(max_length=30, choices=NotificationType.choices, default=NotificationType.SYSTEM)
    data = models.JSONField(default=dict, blank=True)
    is_read = models.BooleanField(default=False, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table = 'notifications'
        verbose_name = 'Notification'
        verbose_name_plural = 'Notifications'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.email} - {self.title} ({'Read' if self.is_read else 'Unread'})"
