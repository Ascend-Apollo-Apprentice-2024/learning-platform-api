from rest_framework import serializers
from LearningAPI.models.people import Cohort


class CohortSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cohort
        fields = '__all__'
