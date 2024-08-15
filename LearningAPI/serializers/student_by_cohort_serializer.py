from rest_framework import serializers

class BookSerializer(serializers.Serializer):
    id = serializers.IntegerField(source='book_id')
    name = serializers.CharField(source='book_name')
    project = serializers.CharField(source='project_name')

class CohortSerializer(serializers.Serializer):
    id = serializers.IntegerField(source='cohort_id')
    name = serializers.CharField(source='cohort_name')
    start_date = serializers.CharField(source='break_start_date')
    end_date = serializers.CharField(source='end_date')

class StudentCohortDataSerializer(serializers.Serializer):
    id = serializers.IntegerField(source='user_id')
    name = serializers.CharField(source='student_name')
    score = serializers.IntegerField()
    tags = serializers.ListField(child=serializers.CharField(), source='tag_name')
    proposals = serializers.ListField(child=serializers.CharField(), source='proposal_status')
    book = BookSerializer(source='*')
    assessment_status = serializers.IntegerField(source='status_id')
    github = serializers.CharField(source='github_handle')
    cohorts = CohortSerializer(source='*', many=True)
    archetype = serializers.CharField(source='briggs_myers_type')
