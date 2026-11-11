from decimal import Decimal
from django.core.exceptions import ValidationError

def validate_positive_amount(value):
    """Ensure monetary value is strictly positive."""
    if value is None or Decimal(str(value)) <= Decimal('0.00'):
        raise ValidationError('Monetary amount must be strictly greater than 0.00.')

def validate_non_negative_amount(value):
    """Ensure monetary value is non-negative."""
    if value is None or Decimal(str(value)) < Decimal('0.00'):
        raise ValidationError('Monetary amount cannot be negative.')
