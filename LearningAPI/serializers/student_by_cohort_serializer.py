import json
from rest_framework import serializers


class StudentCohortDataSerializer(serializers.Serializer):
    proposals = serializers.SerializerMethodField()
    
    def get_proposals(self, obj):
    
     # Assuming the field storing the JSON string is called `json_field`
        json_string = obj["proposals"]  # Replace with the actual field name

        try:
            # Parse the string into a Python list of dictionaries
            parsed_data = json.loads(json_string)
            print(parsed_data)
            return parsed_data  # Return the parsed JSON data as Python objects
        except json.JSONDecodeError:
            return None  # Handle error gracefully, you can return an empty list or None
    
    id = serializers.IntegerField(source='user_id')
    name = serializers.CharField(source='student_name')
    score = serializers.IntegerField()
    tags = serializers.ListField(child=serializers.CharField(), source='tag_name')
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
