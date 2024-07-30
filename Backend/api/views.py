from django.shortcuts import render
from .models import Bookings,CustomUser,Clubs
from rest_framework import generics,status
from rest_framework.response import Response
from rest_framework.views import APIView
from .serializers import UserSerializer,BookingsSerializer,ClubsSerializer
from rest_framework.permissions import IsAuthenticated,AllowAny,IsAdminUser
from rest_framework.decorators import api_view, permission_classes




# Create your views here.
class BookingCreate(generics.ListCreateAPIView):
    serializer_class = BookingsSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return Bookings.objects.filter(user=user)
    
    def perform_create(self, serializer):
        if serializer.is_valid():
            serializer.save(user=self.request.user)
        else:
            print(serializer.errors)

class BookingDelete(generics.DestroyAPIView):
    serializer_class = BookingsSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return Bookings.objects.filter(user=user)



class PrintUserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        serializer = UserSerializer(user)
        return Response(serializer.data, status=status.HTTP_200_OK)
      

class CreateClubView(generics.CreateAPIView):
    queryset = Clubs.objects.all()
    serializer_class = ClubsSerializer
    permission_classes = [IsAdminUser]



class CreateUserView(generics.CreateAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]








