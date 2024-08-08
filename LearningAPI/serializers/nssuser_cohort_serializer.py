from rest_framework import serializers
from LearningAPI.models.people import NssUserCohort


class NssUserCohortSerializer(serializers.ModelSerializer):
    class Meta:
        model = NssUserCohort
        fields = '__all__'
