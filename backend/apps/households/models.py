import uuid
from django.db import models
from django.conf import settings

class MemberRole(models.TextChoices):
    OWNER = 'owner', 'Owner'
    ADMIN = 'admin', 'Administrator'
    MEMBER = 'member', 'Member'
    VIEWER = 'viewer', 'Read-Only Viewer'

class Household(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=120)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='created_households')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'households'

    def __str__(self):
        return self.name

class HouseholdMember(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    household = models.ForeignKey(Household, on_delete=models.CASCADE, related_name='members')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='household_memberships')
    role = models.CharField(max_length=20, choices=MemberRole.choices, default=MemberRole.MEMBER)
    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'household_members'
        unique_together = ('household', 'user')
