from django.db import models


class LearningWeight(models.Model):
    """Model for learning objectives for NSS"""
    label = models.CharField(max_length=127)
    weight = models.IntegerField()
    tier = models.IntegerField(default=1)

    def __str__(self) -> str:
        return f'{self.label} ({self.weight})'
