import uuid
from django.db import models
from django.conf import settings

class CategoryType(models.TextChoices):
    INCOME = 'income', 'Income'
    EXPENSE = 'expense', 'Expense'

class Category(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='categories',
        null=True,
        blank=True,
        help_text="Null for global system categories; set for user-defined custom categories."
    )
    name = models.CharField(max_length=80)
    type = models.CharField(max_length=10, choices=CategoryType.choices, default=CategoryType.EXPENSE)
    icon = models.CharField(max_length=60, default='category')
    color = models.CharField(max_length=20, default='#10B981')
    is_system = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'categories'
        verbose_name = 'Category'
        verbose_name_plural = 'Categories'
        ordering = ['type', 'name']
        constraints = [
            models.UniqueConstraint(
                fields=['user', 'name', 'type'],
                name='unique_user_category_name_type'
            )
        ]

    def __str__(self):
        return f"{self.name} ({self.get_type_display()})"
