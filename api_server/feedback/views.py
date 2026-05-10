from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Feedback
from .serializers import FeedbackSerializer


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def feedback_list_create(request):
    """
    GET  /api/v1/feedback/ — list user's feedback.
    POST /api/v1/feedback/ — submit new feedback.
    """
    if request.method == 'GET':
        feedbacks = Feedback.objects.filter(user=request.user)
        serializer = FeedbackSerializer(feedbacks, many=True)
        return Response(serializer.data)

    serializer = FeedbackSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    serializer.save(user=request.user)
    return Response(serializer.data, status=status.HTTP_201_CREATED)
