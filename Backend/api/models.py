from django.db import models
from django.contrib.auth.models import AbstractUser,Group, Permission



# Create your models here.

class CustomUser(AbstractUser):
    phone = models.CharField(max_length= 15)

    groups = models.ManyToManyField(
        Group,
        related_name='customuser_set',  # Adding a custom related name
        blank=True,
        help_text='The groups this user belongs to. A user will get all permissions granted to each of their groups.',
        related_query_name='customuser',
    )
    user_permissions = models.ManyToManyField(
        Permission,
        related_name='customuser_set',  # Adding a custom related name
        blank=True,
        help_text='Specific permissions for this user.',
        related_query_name='customuser',
    )





    def __str__(self):
        return self.username





class Clubs(models.Model):
    club_name = models.CharField(max_length=30)
    phone = models.CharField(max_length=15,blank=True,null=True)
    location = models.CharField(max_length=100)
    rating = models.DecimalField(range(1,5),decimal_places= 2,max_digits=3)

    
    def __str__(self):
        return self.club_name


class Bookings(models.Model):
    PENDING = 'Pending'
    DONE = 'Done'
    STATUS_CHOICES = [
        (PENDING, 'Pending'),
        (DONE, 'Done')
    ]

    REGULAR = 'Regular'
    PREMIUM = 'Premium'
    SINGLE = 'Single'
    BOOKING_TYPE_CHOICES = [
        (REGULAR, 'Regular'),
        (PREMIUM, 'Premium'),
        (SINGLE, 'Single')
    ]

    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE,related_name= "bookings")
    club = models.ForeignKey(Clubs, on_delete=models.CASCADE,related_name= "booking_I_made")  # Assuming 'Clubs' is another model in your app
    status = models.CharField(max_length=8, choices=STATUS_CHOICES, default=PENDING)
    number_of_people = models.IntegerField()
    booking_type = models.CharField(max_length=10, choices=BOOKING_TYPE_CHOICES, default=REGULAR)
    booked_at = models.DateTimeField()

    def __str__(self):
        return f'Booking {self.id} by {self.user} for {self.club}'
    

class Catalogue(models.Model):
    REGULAR = 'Regular'
    PREMIUM = 'Premium'
    SINGLE = 'Single'
    SERVICE_TYPE_CHOICES = [
        (REGULAR, 'Regular'),
        (PREMIUM, 'Premium'),
        (SINGLE, 'Single')
    ]

    club = models.ForeignKey('Clubs', on_delete=models.CASCADE)
    service_type = models.CharField(max_length=10, choices=SERVICE_TYPE_CHOICES)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    max_person = models.IntegerField()

    def __str__(self):
        return f'{self.club.name} - {self.service_type}: {self.price}'