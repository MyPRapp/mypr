# your_app/backends.py

from django.contrib.auth.backends import ModelBackend
from .models import CustomUser


class CustomBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        try:
            # Attempt to find the user by username
            user = CustomUser.objects.get(username=username)
        except CustomUser.DoesNotExist:
            try:
                # Attempt to find the user by email
                user = CustomUser.objects.get(email=username)
            except CustomUser.DoesNotExist:
                try:
                    # Attempt to find the user by phone
                    user = CustomUser.objects.get(phone=username)
                except CustomUser.DoesNotExist:
                    user = None

        if user is not None and user.check_password(password):
            return user
        return None
