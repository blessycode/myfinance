from rest_framework import permissions

class IsOwner(permissions.BasePermission):
    """
    Object-level permission to only allow owners of an object to access or edit it.
    Assumes model instance has a `user` attribute.
    """
    def has_object_permission(self, request, view, obj):
        if hasattr(obj, 'user'):
            return obj.user == request.user
        return False

class IsAccountOwner(permissions.BasePermission):
    """
    Validates that the current user owns the financial account.
    """
    def has_object_permission(self, request, view, obj):
        if hasattr(obj, 'user'):
            return obj.user == request.user
        elif hasattr(obj, 'account'):
            return obj.account.user == request.user
        return False
