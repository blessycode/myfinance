import json
from django.core.cache import cache
from django.http import JsonResponse

class IdempotencyMiddleware:
    """
    Prevents duplicate financial submissions via Idempotency-Key header.
    Cached responses are returned directly if duplicate key is presented within 5 minutes.
    """
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        idempotency_key = request.headers.get('Idempotency-Key')
        if not idempotency_key or request.method not in ('POST', 'PUT', 'PATCH'):
            return self.get_response(request)

        user_id = request.user.id if request.user.is_authenticated else 'anon'
        cache_key = f'idempotency:{user_id}:{idempotency_key}'

        cached_data = cache.get(cache_key)
        if cached_data:
            return JsonResponse(
                cached_data['data'],
                status=cached_data['status'],
                safe=False
            )

        response = self.get_response(request)

        # Cache successful mutations (200-299)
        if 200 <= response.status_code < 300:
            try:
                content = json.loads(response.content.decode('utf-8'))
                cache.set(cache_key, {'data': content, 'status': response.status_code}, timeout=300)
            except Exception:
                pass

        return response
