from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status

def custom_exception_handler(exc, context):
    """
    Standardizes error responses across all endpoints:
    {
      "success": false,
      "message": "...",
      "errors": ...,
      "status_code": 400
    }
    """
    response = exception_handler(exc, context)

    if response is not None:
        message = 'Validation or processing error occurred'
        errors = response.data

        if isinstance(response.data, dict):
            if 'detail' in response.data:
                message = str(response.data['detail'])
                errors = response.data
            elif 'non_field_errors' in response.data:
                message = str(response.data['non_field_errors'][0])
        elif isinstance(response.data, list) and len(response.data) > 0:
            message = str(response.data[0])

        custom_response_data = {
            'success': False,
            'message': message,
            'errors': errors,
            'status_code': response.status_code
        }
        response.data = custom_response_data

    return response
