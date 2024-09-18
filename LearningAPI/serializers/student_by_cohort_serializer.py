import json
from rest_framework import serializers


class StudentCohortDataSerializer(serializers.Serializer):
    proposals = serializers.SerializerMethodField()
    book = serializers.SerializerMethodField()
    cohort = serializers.SerializerMethodField()
    
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
        
    def get_book(self, obj):
        
       return {
                "id": obj["book_id"],
                "name": obj["book_name"],
                "project": obj["project_name"]
            }

    def get_cohort(self, obj):
        
       return {
                "id": obj["cohort_id"],
                "name": obj["cohort_name"],
                "start_date": obj["break_start_date"]
            }
    
    id = serializers.IntegerField(source='user_id')
    name = serializers.CharField(source='student_name')
    score = serializers.IntegerField()
    tags = serializers.ListField(child=serializers.CharField(), source='tag_name')
    assessment_status = serializers.IntegerField(source='status_id')
    github = serializers.CharField(source='github_handle')
    archetype = serializers.CharField(source='briggs_myers_type')
    end_date = serializers.CharField()
