from rest_framework import serializers
from .models import Bookings,CustomUser,Clubs,Catalogue

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ["id","username","password","first_name","last_name","email","phone",]
        extra_kwargs = {"password":{"write_only":True}}

    def create(self,validated_data):
        user = CustomUser.objects.create_user(**validated_data)
        return user



class BookingsSerializer(serializers.ModelSerializer):
    club_name = serializers.CharField(write_only=True)
    club = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = Bookings
        fields = ['id', 'club', 'club_name', 'user', 'status', 'number_of_people', 'booking_type', 'booked_at']
        extra_kwargs = {
            'user': {'read_only': True},
            'club': {'read_only': True},
        }

    def create(self, validated_data):
        club_name = validated_data.pop('club_name')
        try:
            club = Clubs.objects.get(club_name=club_name)
        except Clubs.DoesNotExist:
            raise serializers.ValidationError(f'Club with name "{club_name}" does not exist.')
        
        validated_data['club'] = club
        return super().create(validated_data)

class ClubsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Clubs
        fields = ["id","club_name","phone","location","rating","availability","photos"]


class CatalogueSerializer(serializers.ModelSerializer):
    class Meta:
        model = Catalogue
        fields = ['club','service_type', 'price', 'max_person']
