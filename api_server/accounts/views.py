from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework import viewsets, status

from django.contrib.auth.hashers import check_password, make_password
from .serializers import RegisterSerializer, LoginSerializer, UserProfileSerializer, UserAddressSerializer
from .models import UserAddress


@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    """Register a new user with phone + 4-digit PIN."""
    serializer = RegisterSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = serializer.save()
    token, _ = Token.objects.get_or_create(user=user)
    return Response(
        {
            'token': token.key,
            'user': UserProfileSerializer(user).data,
        },
        status=status.HTTP_201_CREATED,
    )


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    """Login with phone + 4-digit PIN → returns auth token."""
    serializer = LoginSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = serializer.validated_data['user']
    token, _ = Token.objects.get_or_create(user=user)
    return Response({
        'token': token.key,
        'user': UserProfileSerializer(user).data,
    })


@api_view(['GET', 'PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser, JSONParser])
def profile_view(request):
    """Get or update the authenticated user's profile."""
    if request.method == 'GET':
        serializer = UserProfileSerializer(request.user)
        return Response(serializer.data)

    serializer = UserProfileSerializer(
        request.user, data=request.data, partial=True
    )
    serializer.is_valid(raise_exception=True)
    serializer.save()
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_pin_view(request):
    """Change the user's 4-digit PIN."""
    old_pin = request.data.get('old_pin')
    new_pin = request.data.get('new_pin')

    if not old_pin or not new_pin:
        return Response({'detail': 'Old and new PIN are required.'}, status=status.HTTP_400_BAD_REQUEST)

    if not str(new_pin).isdigit() or len(str(new_pin)) != 4:
        return Response({'detail': 'New PIN must be exactly 4 digits.'}, status=status.HTTP_400_BAD_REQUEST)

    user = request.user
    if not check_password(old_pin, user.pin):
        return Response({'detail': 'Invalid old PIN.'}, status=status.HTTP_400_BAD_REQUEST)

    user.pin = make_password(new_pin)
    user.save()
    return Response({'detail': 'PIN changed successfully.'})


class UserAddressViewSet(viewsets.ModelViewSet):
    """ViewSet for authenticated users to manage their addresses."""
    serializer_class = UserAddressSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = None

    def get_queryset(self):
        return UserAddress.objects.filter(user=self.request.user)
