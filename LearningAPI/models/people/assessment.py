"""Model for assessments used by instruction team"""
from django.db import models


class Assessment(models.Model):
    """Model for assessments used by instruction team"""
    ASSESSMENT_TYPES = (
        ("SELF", 'Self-assessment'),
        ("ASSIGNED", 'Assigned by instructor'),
    )
    name = models.CharField(max_length=255)
    source_url = models.CharField(max_length=512)
    book = models.ForeignKey("Book", on_delete=models.CASCADE, default=1, related_name="assessments")
    type = models.CharField(
        max_length=8,
        choices=ASSESSMENT_TYPES,
        default="SELF",
    )
    objectives = models.ManyToManyField("LearningWeight", through='AssessmentWeight')

    @property
    def assigned_book(self):
        return {
            "id": self.book.id,
            "name": self.book.name
        }

    @property
    def course(self):
        return {
            "id": self.book.course.id,
            "name": self.book.course.name
        }

    def __str__(self):
        return self.name
