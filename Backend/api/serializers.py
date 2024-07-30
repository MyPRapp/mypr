from rest_framework import serializers
from .models import Bookings,CustomUser,Clubs

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ["id","username","password","first_name","last_name","email","phone",]
        extra_kwargs = {"password":{"write_only":True}}

    def create(self,validated_data):
        user = CustomUser.objects.create_user(**validated_data)
        return user



class BookingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Bookings
        fields = ["id","club","booking_type","booked_at"]
        #fields = ["id","club","user","status","number_of_people","booking_type","booked_at"]
        extra_kwargs = {"user":{"read_only": True}}

class ClubsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Clubs
        fields = ["id","club_name","phone","location"]

