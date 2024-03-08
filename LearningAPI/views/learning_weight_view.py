from django.http.response import HttpResponseServerError
from rest_framework import serializers, status
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAdminUser
from rest_framework.viewsets import ModelViewSet
from rest_framework.response import Response
from LearningAPI.models.skill import LearningWeight


class LearningWeightSerializer(serializers.ModelSerializer):
    """JSON serializer"""

    class Meta:
        model = LearningWeight
        fields = '__all__'

class LargeResultsSetPagination(PageNumberPagination):
    page_size = 50
    page_size_query_param = 'page_size'
    max_page_size = 100

class LearningWeightViewSet(ModelViewSet):
    """
    A simple ViewSet for viewing and editing learning weights.
    """
    queryset = LearningWeight.objects.all().order_by("tier")
    serializer_class = LearningWeightSerializer
    permission_classes = [IsAdminUser]
    pagination_class = LargeResultsSetPagination

    def list(self, request):
        """Handle GET requests for all items

        Returns:
            Response -- JSON serialized array
        """
        student = self.request.query_params.get('studentId', None)
        min_tier = self.request.query_params.get('tiermin', None)
        max_tier = self.request.query_params.get('tiermax', None)

        try:
            if student is not None:
                weights = LearningWeight.objects\
                    .raw("""
                        select w.id,
                            w.label,
                            w.weight,
                            w.tier,
                            r.achieved,
                            r.student_id
                        from public."LearningAPI_learningweight" w
                        left outer join public."LearningAPI_learningrecord" r
                            on r.weight_id = w.id
                                and
                                r.student_id = %s
                        where r.achieved is NULL
                        order by w.tier
                    """,
                    [student])
            else:
                if min_tier is not None and max_tier is not None:
                    weights = LearningWeight.objects.filter(tier__gte=min_tier, tier__lte=max_tier).order_by('tier')

                else:
                    weights = LearningWeight.objects.all().order_by('tier')

            serializer = LearningWeightSerializer(
                weights, many=True, context={'request': request})
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as ex:
            return HttpResponseServerError(ex)
