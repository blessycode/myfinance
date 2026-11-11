from rest_framework.renderers import JSONRenderer

class StandardAPIRenderer(JSONRenderer):
    """
    Standardizes JSON responses into an enterprise envelope:
    {
      "success": true,
      "message": "...",
      "data": ...
    }
    """
    def render(self, data, accepted_media_type=None, renderer_context=None):
        if renderer_context is None:
            return super().render(data, accepted_media_type, renderer_context)

        response = renderer_context.get('response')
        request = renderer_context.get('request')

        # Skip formatting for OpenAPI schema or docs endpoints
        if request and (request.path.startswith('/api/schema') or request.path.startswith('/api/docs')):
            return super().render(data, accepted_media_type, renderer_context)

        # Skip if response is an error or already wrapped
        status_code = response.status_code if response else 200
        if status_code >= 400 or (isinstance(data, dict) and 'success' in data):
            return super().render(data, accepted_media_type, renderer_context)

        message = 'Request completed successfully'
        if isinstance(data, dict) and 'detail' in data:
            message = data.pop('detail')

        wrapped_data = {
            'success': True,
            'message': message,
            'data': data
        }

        return super().render(wrapped_data, accepted_media_type, renderer_context)
