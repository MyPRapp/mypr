from django.shortcuts import render,redirect
from django.db.models import Q
from .models import Bookings,CustomUser,Clubs,Catalogue
from rest_framework import generics,status
from rest_framework.response import Response
from rest_framework.views import APIView
from .serializers import UserSerializer,BookingsSerializer,ClubsSerializer,CatalogueSerializer
from rest_framework.permissions import IsAuthenticated,AllowAny,IsAdminUser
from rest_framework.decorators import api_view, permission_classes
from django.contrib.auth.forms import PasswordResetForm,SetPasswordForm
from django.template.loader import render_to_string
from django.utils.http import urlsafe_base64_encode,urlsafe_base64_decode
from django.utils.encoding import force_bytes,force_str
from django.contrib.auth.tokens import default_token_generator
from django.core.mail import send_mail







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
        user = self.request.user
        user.points += 50
        user.save()


class BookingDelete(generics.DestroyAPIView):
    serializer_class = BookingsSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return Bookings.objects.filter(user=user)


#User related functions



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




#points related functions
class ReducePointsView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        points_to_reduce = request.data.get('points', 0)

        try:
            points_to_reduce = int(points_to_reduce)
        except ValueError:
            return Response({"error": "Invalid points value."}, status=status.HTTP_400_BAD_REQUEST)

        if points_to_reduce <= 0:
            return Response({"error": "Points to reduce must be greater than zero."}, status=status.HTTP_400_BAD_REQUEST)

        if user.points < points_to_reduce:
            return Response({"error": "Not enough points to reduce."}, status=status.HTTP_400_BAD_REQUEST)

        user.points -= points_to_reduce
        user.save()

        return Response({"detail": f"{points_to_reduce} points reduced.", "current_points": user.points}, status=status.HTTP_200_OK)
    


class PasswordResetRequestView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        if email:
            associated_users = CustomUser.objects.filter(Q(email=email))
            if associated_users.exists():
                for user in associated_users:
                    subject = "Password Reset Requested"
                    email_template_name = "password_reset_email.txt"
                    c = {
                        "email": user.email,
                        'domain': '127.0.0.1:8000',  # Replace with your frontend domain
                        'site_name': 'MyPr',
                        "uid": urlsafe_base64_encode(force_bytes(user.pk)),
                        "user": user,
                        'token': default_token_generator.make_token(user),
                        'protocol': 'http',
                    }
                    email_content = render_to_string(email_template_name, c)
                    send_mail(subject, email_content, 'admin@yourdomain.com', [user.email], fail_silently=False)
                return Response({"detail": "Password reset email sent."}, status=status.HTTP_200_OK)
        return Response({"error": "Invalid email address"}, status=status.HTTP_400_BAD_REQUEST)


class PasswordResetConfirmView(APIView):
    def post(self, request, uidb64, token):
        try:
            uid = force_str(urlsafe_base64_decode(uidb64))
            user = CustomUser.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, CustomUser.DoesNotExist):
            user = None

        if user is not None and default_token_generator.check_token(user, token):
            form = SetPasswordForm(user, request.data)
            if form.is_valid():
                form.save()
                return Response({"detail": "Password has been reset."}, status=status.HTTP_200_OK)
            else:
                return Response(form.errors, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response({"error": "Invalid token or user ID"}, status=status.HTTP_400_BAD_REQUEST)

def reset_password_page_view(request):
    return render(request, 'password_reset_page.html')

