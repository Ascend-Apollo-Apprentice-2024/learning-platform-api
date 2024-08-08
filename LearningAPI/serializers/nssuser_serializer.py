from rest_framework import serializers
from LearningAPI.models.people import NssUser


class NssUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = NssUser
        fields = ('url', 'slack_handle', 'github_handle', 'mentor', 'user')