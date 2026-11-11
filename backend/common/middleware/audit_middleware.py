class AuditMiddleware:
    """
    Captures client IP and User-Agent and attaches to request for audit logging.
    """
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0].strip()
        else:
            ip = request.META.get('REMOTE_ADDR', '')
        request.client_ip = ip
        request.user_agent = request.META.get('HTTP_USER_AGENT', '')
        return self.get_response(request)
