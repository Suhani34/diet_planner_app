from django.urls import path
from .views import generate_meal_plan, get_latest_meal_plan

urlpatterns = [
    path('generate-meal-plan/', generate_meal_plan, name='generate_meal_plan'),
    path('meal-plan/<str:firebase_uid>/', get_latest_meal_plan, name='get_latest_meal_plan'),
]