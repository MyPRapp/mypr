from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.mail import send_mail
from .models import Bookings,Catalogue
from django.conf import settings



@receiver(post_save, sender=Bookings)
def send_booking_email_user(sender, instance, created, **kwargs):
    if created:
        catalogue_prices = Catalogue.objects.filter(club = instance.club.id)
        binary_table = list(instance.booking_type)
        prices = [catalogue.price for catalogue in catalogue_prices]
        bit = []
        for i in range(0,4): #change index here if the booking_type changes field length
            bit.append(binary_table[i])
        price = 0
        i = 0
        print(binary_table)
        while i < len(prices):
            price = price + int(prices[i])*int(bit[i])
            i += 1
        price = price*((10-int(bit[len(bit)-1]))/10)

        subject = f"Thank you for using our services :)"
        message = f"Below are the details of your booking,MyPr team wished you to have a great time!.\n\nDetails:\n\nUser ID:{instance.user.id}\nBooking ID: {instance.id}\nUser: {instance.user.username}\nClub: {instance.club.club_name}\nBooking Type: {instance.booking_type}\nBooked At: {instance.booked_at}\nNumber of People: {instance.number_of_people}\nComments: {instance.comments}\nPrice: {price}"
        from_email = settings.EMAIL_HOST_USER
        recipient_list = [instance.user.email]

        send_mail(subject, message, from_email, recipient_list)

@receiver(post_save, sender=Bookings)
def send_booking_email_admin(sender, instance, created, **kwargs):
    if created:
        catalogue_prices = Catalogue.objects.filter(club = instance.club.id)
        binary_table = list(instance.booking_type)
        prices = [catalogue.price for catalogue in catalogue_prices]
        bit = []
        for i in range(0,4): #change index here if the booking_type changes field length
            bit.append(binary_table[i])
        price = 0
        i = 0
        print(binary_table)
        while i < len(prices):
            price = price + int(prices[i])*int(bit[i])
            i += 1
        price = price*((10-int(bit[len(bit)-1]))/10)

        subject = f"A user has made a new booking: {instance.id}"
        message = f"A very  new booking has been created.\n\nDetails:\n\nUser ID:{instance.user.id}\nBooking ID: {instance.id}\nUser: {instance.user.username}\nClub: {instance.club.club_name}\nBooking Type: {instance.booking_type}\nBooked At: {instance.booked_at}\nNumber of People: {instance.number_of_people}\nComments: {instance.comments}\nPrice: {price}"
        from_email = settings.EMAIL_HOST_USER
        recipient_list = [settings.EMAIL_HOST_USER]

        send_mail(subject, message, from_email, recipient_list)


# def send_phone_authentication_sms(request):
#     phone_number = '+306980984213'
#     message = 'Hello, this is a test SMS message.'
#     send_sms(phone_number, message)
