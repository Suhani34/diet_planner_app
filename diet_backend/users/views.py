from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import UserProfile
from .serializers import UserProfileSerializer


@api_view(['POST'])
def save_profile(request):
    firebase_uid = request.data.get('firebase_uid')

    if not firebase_uid:
        return Response(
            {'error': 'firebase_uid is required'},
            status=status.HTTP_400_BAD_REQUEST
        )

    instance = UserProfile.objects.filter(firebase_uid=firebase_uid).first()

    serializer = UserProfileSerializer(instance=instance, data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
def get_profile(request, firebase_uid):
    try:
        profile = UserProfile.objects.get(firebase_uid=firebase_uid)
    except UserProfile.DoesNotExist:
        return Response(
            {'error': 'Profile not found'},
            status=status.HTTP_404_NOT_FOUND
        )

    serializer = UserProfileSerializer(profile)
    return Response(serializer.data)


@api_view(['GET'])
def profile_status(request, firebase_uid):
    try:
        profile = UserProfile.objects.get(firebase_uid=firebase_uid)
        return Response({'profile_complete': profile.profile_complete})
    except UserProfile.DoesNotExist:
        return Response({'profile_complete': False})