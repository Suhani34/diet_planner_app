from django.urls import path
from .views import save_profile, get_profile, profile_status

urlpatterns = [
    path('profile/', save_profile, name='save_profile'),
    path('profile/<str:firebase_uid>/', get_profile, name='get_profile'),
    path('profile/<str:firebase_uid>/status/', profile_status, name='profile_status'),
]