from django.shortcuts import render
from .models import Bookings,CustomUser,Clubs,Catalogue
from rest_framework import generics,status
from rest_framework.response import Response
from rest_framework.views import APIView
from .serializers import UserSerializer,BookingsSerializer,ClubsSerializer,CatalogueSerializer
from rest_framework.permissions import IsAuthenticated,AllowAny,IsAdminUser
from rest_framework.decorators import api_view, permission_classes


# Create your views here.


#Bookings realated functions
class BookingCreate(generics.ListCreateAPIView):
    serializer_class = BookingsSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return Bookings.objects.filter(user=user)
    
    def perform_create(self, serializer):
            serializer.save(user=self.request.user)


class BookingDelete(generics.DestroyAPIView):
    serializer_class = BookingsSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return Bookings.objects.filter(user=user)


#User related functions
class PrintUserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        serializer = UserSerializer(user)
        return Response(serializer.data, status=status.HTTP_200_OK)
      

class CreateUserView(generics.CreateAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]


#Club related functions

class ClubCatalogueView(generics.ListAPIView):
    serializer_class = CatalogueSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        club_id = self.kwargs['club_id']
        return Catalogue.objects.filter(club_id=club_id)



class CatalogueCreateView(generics.CreateAPIView):
    queryset = Catalogue.objects.all()
    serializer_class = CatalogueSerializer
    permission_classes = [AllowAny]



class CreateClubView(generics.CreateAPIView):
    queryset = Clubs.objects.all()
    serializer_class = ClubsSerializer
    permission_classes = [IsAdminUser]

class PrintAllClubs(generics.ListAPIView):
    queryset = Clubs.objects.all()
    serializer_class = ClubsSerializer            
    permission_classes = [AllowAny]




