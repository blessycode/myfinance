from rest_framework import serializers
from .models import Profile

class ProfileSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(source='user.email', read_only=True)
    first_name = serializers.CharField(source='user.first_name', required=False)
    last_name = serializers.CharField(source='user.last_name', required=False)
    phone_number = serializers.CharField(source='user.phone_number', required=False)

    class Meta:
        model = Profile
        fields = [
            'id',
            'email',
            'first_name',
            'last_name',
            'phone_number',
            'avatar',
            'country',
            'preferred_currency',
            'timezone',
            'language',
            'date_of_birth',
            'notification_preferences',
            'security_preferences',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'email', 'created_at', 'updated_at']

    def update(self, instance, validated_data):
        user_data = validated_data.pop('user', {})
        if user_data:
            user = instance.user
            for key, val in user_data.items():
                setattr(user, key, val)
            user.save()

        for key, val in validated_data.items():
            setattr(instance, key, val)
        instance.save()
        return instance

class SettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = [
            'preferred_currency',
            'timezone',
            'language',
            'notification_preferences',
            'security_preferences',
        ]
