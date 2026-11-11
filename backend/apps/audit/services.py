from .models import AuditLog

class AuditService:
    @staticmethod
    def log(user, action: str, request=None, details: dict = None):
        ip = getattr(request, 'client_ip', None) if request else None
        agent = getattr(request, 'user_agent', '') if request else ''
        return AuditLog.objects.create(
            user=user if user and user.is_authenticated else None,
            action=action,
            ip_address=ip,
            user_agent=agent[:255] if agent else '',
            details=details or {}
        )
