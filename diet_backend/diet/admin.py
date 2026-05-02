from django.contrib import admin
from .models import MealPlan
from users.models import UserProfile

admin.site.register(MealPlan)
admin.site.register(UserProfile)