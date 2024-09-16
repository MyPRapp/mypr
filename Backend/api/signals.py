# yourapp/signals.py


from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.mail import send_mail
from .models import Bookings
from django.conf import settings

@receiver(post_save, sender=Bookings)
def send_booking_email(sender, instance, created, **kwargs):
    if created:
        subject = f"New Booking Created: {instance.id}"
        message = f"A new booking has been created.\n\nDetails:\n\nBooking ID: {instance.id}\nUser: {instance.user.username}\nClub: {instance.club.club_name}\nBooking Type: {instance.booking_type}\nBooked At: {instance.booked_at}\nNumber of People: {instance.number_of_people}"
        from_email = settings.EMAIL_HOST_USER
        recipient_list = [settings.EMAIL_HOST_USER,instance.user.email]  # you can add more recipients here

        send_mail(subject, message, from_email, recipient_list)
