from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from users.models import UserProfile
from .models import MealPlan
from .serializers import MealPlanSerializer
from .services.meal_generator import generate_ai_meal_plan


@api_view(['POST'])
def generate_meal_plan(request):
    firebase_uid = request.data.get('firebase_uid')

    if not firebase_uid:
        return Response(
            {'error': 'firebase_uid is required'},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        profile = UserProfile.objects.get(firebase_uid=firebase_uid)
    except UserProfile.DoesNotExist:
        return Response(
            {'error': 'Profile not found'},
            status=status.HTTP_404_NOT_FOUND
        )

    try:
        generated = generate_ai_meal_plan(profile)
    except Exception as e:
        return Response(
            {'error': f'AI generation failed: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

    meal_plan = MealPlan.objects.create(
        firebase_uid=firebase_uid,
        day_number=generated['day_number'],
        total_calories=generated['total_calories'],
        protein_g=generated['protein_g'],
        carbs_g=generated['carbs_g'],
        fats_g=generated['fats_g'],
        meals=generated['meals'],
        raw_ai_response=generated['raw_ai_response'],
    )

    serializer = MealPlanSerializer(meal_plan)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['GET'])
def get_latest_meal_plan(request, firebase_uid):
    meal_plan = MealPlan.objects.filter(firebase_uid=firebase_uid).order_by('-created_at').first()

    if not meal_plan:
        return Response(
            {'error': 'Meal plan not found'},
            status=status.HTTP_404_NOT_FOUND
        )

    serializer = MealPlanSerializer(meal_plan)
    return Response(serializer.data, status=status.HTTP_200_OK)