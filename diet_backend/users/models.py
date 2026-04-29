from django.db import models


class UserProfile(models.Model):
    firebase_uid = models.CharField(max_length=255, unique=True)
    email = models.EmailField(blank=True, null=True)
    full_name = models.CharField(max_length=255, blank=True, null=True)

    age = models.IntegerField(blank=True, null=True)
    gender = models.CharField(max_length=50, blank=True, null=True)
    height = models.FloatField(blank=True, null=True)
    weight = models.FloatField(blank=True, null=True)

    goal = models.CharField(max_length=100, blank=True, null=True)
    activity_level = models.CharField(max_length=100, blank=True, null=True)
    diet_preference = models.CharField(max_length=100, blank=True, null=True)
    meal_frequency = models.CharField(max_length=100, blank=True, null=True)
    timeline = models.CharField(max_length=100, blank=True, null=True)
    budget = models.CharField(max_length=100, blank=True, null=True)
    cuisine = models.CharField(max_length=100, blank=True, null=True)

    allergies = models.JSONField(default=list, blank=True)
    medical_conditions = models.JSONField(default=list, blank=True)

    profile_complete = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.email or self.firebase_uid