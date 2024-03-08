"""Model for student assessments"""
from django.db import models
from . import Assessment, StudentAssessmentStatus, NssUser


class StudentAssessment(models.Model):
    """Model for assessments assigned to a student"""
    student = models.ForeignKey(NssUser, on_delete=models.DO_NOTHING, related_name='assessments')
    assessment = models.ForeignKey(Assessment, on_delete=models.CASCADE, related_name='students')
    status = models.ForeignKey(StudentAssessmentStatus, on_delete=models.DO_NOTHING)
    instructor = models.ForeignKey(NssUser, null=True, on_delete=models.SET_NULL, related_name='assignments')
    url = models.CharField(max_length=512, default="")
    date_created = models.DateField(auto_now=True, auto_now_add=False)

    def __str__(self):
        return f'{self.student} and {self.assessment} is {self.status}'

    class Meta:
        unique_together = (('student', 'assessment',),)
