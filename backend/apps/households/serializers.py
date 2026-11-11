from rest_framework import serializers
from .models import Household, HouseholdMember

class HouseholdMemberSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(source='user.email', read_only=True)
    full_name = serializers.CharField(source='user.full_name', read_only=True)

    class Meta:
        model = HouseholdMember
        fields = ['id', 'user', 'email', 'full_name', 'role', 'joined_at']
        read_only_fields = ['id', 'joined_at']

class HouseholdSerializer(serializers.ModelSerializer):
    members = HouseholdMemberSerializer(many=True, read_only=True)

    class Meta:
        model = Household
        fields = ['id', 'name', 'created_by', 'members', 'created_at']
        read_only_fields = ['id', 'created_by', 'created_at']

    def create(self, validated_data):
        user = self.context['request'].user
        household = Household.objects.create(created_by=user, **validated_data)
        HouseholdMember.objects.create(household=household, user=user, role='owner')
        return household
