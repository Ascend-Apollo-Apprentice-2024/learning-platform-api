from rest_framework import serializers


class StudentCohortDataSerializer(serializers.Serializer):
    id = serializers.IntegerField(source='user_id')
    name = serializers.CharField(source='student_name')
    score = serializers.IntegerField()
    tags = serializers.ListField(child=serializers.CharField(), source='tag_name')
    proposals = serializers.ListField(child=serializers.CharField())
    assessment_status = serializers.IntegerField(source='status_id')
    github = serializers.CharField(source='github_handle')
    archetype = serializers.CharField(source='briggs_myers_type')
    cohort_id = serializers.IntegerField()
    name = serializers.CharField(source='cohort_name')
    start_date = serializers.CharField(source='break_start_date')
    end_date = serializers.CharField()
    book_id = serializers.IntegerField()
    name = serializers.CharField(source='book_name')
    project = serializers.CharField(source='project_name')