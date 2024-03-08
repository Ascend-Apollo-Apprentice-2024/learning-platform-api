from django.db import models


class CohortCourse(models.Model):
    """Model for storing which courses a cohort will experience"""
    cohort = models.ForeignKey("Cohort", on_delete=models.CASCADE, related_name="courses")
    course = models.ForeignKey("Course", on_delete=models.CASCADE, related_name="cohorts")
    active = models.BooleanField(default=False)
    index = models.SmallIntegerField(default=1)

    class Meta:
        unique_together = (('cohort', 'course',),)
