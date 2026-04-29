from django.db import models


class MealPlan(models.Model):
    firebase_uid = models.CharField(max_length=255)
    day_number = models.IntegerField(default=1)

    total_calories = models.IntegerField(default=0)
    protein_g = models.FloatField(default=0)
    carbs_g = models.FloatField(default=0)
    fats_g = models.FloatField(default=0)

    meals = models.JSONField(default=dict, blank=True)
    raw_ai_response = models.TextField(blank=True, null=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.firebase_uid} - Day {self.day_number}"