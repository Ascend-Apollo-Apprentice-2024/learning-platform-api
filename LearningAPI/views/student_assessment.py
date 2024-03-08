"""Assessment view module"""
import os
import requests

from django.http import HttpResponseServerError
from django.utils.decorators import method_decorator

from rest_framework import permissions, serializers, status
from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response
from rest_framework.viewsets import ViewSet

from LearningAPI.decorators import is_instructor
from LearningAPI.models.people import (Assessment, NssUser, StudentAssessment,
                                       StudentAssessmentStatus)
from LearningAPI.models.coursework import Book
from LearningAPI.models.skill import AssessmentWeight, LearningWeight


class StudentAssessmentPermission(permissions.BasePermission):
    """Custom permissions for Assessment view"""
    def has_permission(self, request, view):
        if view.action in [ 'destroy',]:
            return request.auth.user.is_staff
        elif view.action in ['list', 'retrieve', 'update', 'partial_update', 'create']:
            return True
        else:
            return False


class StudentAssessmentPagination(PageNumberPagination):
    """Custom pagination for Assessment view"""
    page_size = 40
    page_size_query_param = 'page_size'
    max_page_size = 80


class StudentAssessmentView(ViewSet):
    """Student view set"""

    permission_classes = (StudentAssessmentPermission,)
    pagination_class = StudentAssessmentPagination

    @method_decorator(is_instructor())
    def create(self, request):
        """Handle POST operations

        Returns:
            Response -- JSON serialized instance
        """
        book_id = request.data.get("bookId", None)
        source_url = request.data.get("sourceURL", None)
        name = request.data.get("name", None)
        objectives = request.data.get("objectives", None)

        if name is not None and \
            source_url is not None and \
            objectives is not None and \
            book_id is not None and\
            request.auth.user.is_staff:

            assmt = Assessment()
            assmt.name = request.data["name"]
            assmt.source_url = request.data["sourceURL"]

            try:
                assmt.book = Book.objects.get(pk=book_id)
            except Book.DoesNotExist:
                return Response({'reason': 'Invalid book id sent'}, status=status.HTTP_400_BAD_REQUEST)

            assmt.save()

            for objective in objectives:
                AssessmentWeight.objects.create(
                    assessment = assmt,
                    weight_id = objective
                )

            serializer = AssessmentSerializer(assmt)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        else:
            student_assessment = StudentAssessment()
            student_assessment.student = NssUser.objects.get(pk=request.data["studentId"])
            student_assessment.assessment = Assessment.objects.get(pk=request.data["assessmentId"])
            student_assessment.status = StudentAssessmentStatus.objects.get(status="In Progress")

            try:
                student_assessment.save()
                serializer = StudentAssessmentSerializer(student_assessment)
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            except Exception as ex:
                return Response({"reason": ex.args[0]}, status=status.HTTP_400_BAD_REQUEST)

    def list(self, request):
        """Listing all assessments"""
        if "studentId" in request.query_params:
            student = NssUser.objects.get(pk=request.query_params["studentId"])
            student_assessments = StudentAssessment.objects.filter(student=student)

            try:
                serializer = StudentAssessmentSerializer(student_assessments, many=True)
                return Response(serializer.data, status=status.HTTP_200_OK)
            except Exception as ex:
                return Response({"reason": ex.args[0]}, status=status.HTTP_400_BAD_REQUEST)

        else:
            assessments = Assessment.objects.all()
            serializer = AssessmentSerializer(assessments, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)

    def retrieve(self, request, pk=None):
        """Handle GET requests for single item

        Returns:
            Response -- JSON serialized instance
        """
        try:
            assessment = StudentAssessment.objects.get(pk=pk)

            if request.auth.user == assessment.student or request.auth.user.is_staff:
                serializer = StudentAssessmentSerializer(assessment)
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                return Response(
                    {"message": "You are not authorized to view this student profile."},
                    status=status.HTTP_401_UNAUTHORIZED)

        except StudentAssessment.DoesNotExist:
            return Response(
                {"message": "That student assessment does not exist."},
                status=status.HTTP_404_NOT_FOUND)

        except Exception as ex:
            return HttpResponseServerError(ex)

    def update(self, request, pk=None):
        """Handle PUT requests

        Returns:
            Response -- Empty body with 204 status code
        """
        try:
            assessment = StudentAssessment.objects.get(pk=pk)
            assessment_status = StudentAssessmentStatus.objects.get(pk=request.data["status"])

            # Only allow student owner of assessment or an instructor to modify
            if request.auth.user == assessment.student.user or request.auth.user.is_staff:

                # Return 400 if no status change
                if assessment.status == assessment_status:
                    return Response({ "message": "No change in status"}, status=status.HTTP_400_BAD_REQUEST)

                # Student cannot change status to reviewed
                if request.auth.user == assessment.student.user and assessment_status.status not in ("In Progress", "Ready for Review", ):
                    return Response(None, status=status.HTTP_401_UNAUTHORIZED)

                # If an instructor changed the status, record the instructor
                if request.auth.user.is_staff:
                    assessment.instructor = NssUser.objects.get(user=request.auth.user)

                # Set new status and save
                assessment.status = assessment_status
                assessment.save()

                # Send message to student
                try:
                    if assessment.status.status == 'Reviewed and Complete':
                        headers = {
                            "Content-Type": "application/x-www-form-urlencoded"
                        }
                        channel_payload = {
                            "text": request.data.get(
                                "text",
                                f':fox-yay-woo-hoo: Self-Assessment Review Complete\n\n\n:white_check_mark: Your coaching team just marked {assessment.assessment.name} as completed.\n\nVisit https://learning.nss.team to view your messages.'),
                            "token": os.getenv("SLACK_BOT_TOKEN"),
                            "channel": assessment.student.slack_handle
                        }

                        requests.post(
                            "https://slack.com/api/chat.postMessage",
                            data=channel_payload,
                            headers=headers
                        )
                except Exception:
                    pass


                return Response(None, status=status.HTTP_204_NO_CONTENT)
            else:
                return Response(None, status=status.HTTP_401_UNAUTHORIZED)

        except StudentAssessment.DoesNotExist:
            return Response(None, status=status.HTTP_404_NOT_FOUND)

        except Exception as ex:
            return HttpResponseServerError(ex)

    def destroy(self, request, pk=None):
        """Handle DELETE requests for a single student

        Returns:
            Response -- 200, 404, or 500 status code
        """
        try:
            assessment = Assessment.objects.get(pk=pk)
            assessment.delete()

            return Response(None, status=status.HTTP_204_NO_CONTENT)

        except StudentAssessment.DoesNotExist as ex:
            return Response({'message': ex.args[0]}, status=status.HTTP_404_NOT_FOUND)

        except Exception as ex:
            return Response({'message': ex.args[0]}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class AssessmentObjectiveSerializer(serializers.ModelSerializer):
    """JSON serializer"""

    class Meta:
        model = LearningWeight
        fields = ('id', 'label', )

class AssessmentSerializer(serializers.ModelSerializer):
    """JSON serializer"""
    objectives = AssessmentObjectiveSerializer(many=True)

    class Meta:
        model = Assessment
        fields = ('id', 'name', 'source_url', 'assigned_book', 'course', 'objectives' )

class StudentAssessmentSerializer(serializers.ModelSerializer):
    """JSON serializer"""
    assessment = serializers.SerializerMethodField()
    status = serializers.SerializerMethodField()

    def get_assessment(self, obj):
        """Return just the name of the assessment"""
        return {
            "id": obj.assessment.id,
            "name": obj.assessment.name
        }

    def get_status(self, obj):
        """Return the status of assessment"""
        return obj.status.status
    class Meta:
        model = StudentAssessment
        fields = ('id', 'assessment', 'status', 'url', )
