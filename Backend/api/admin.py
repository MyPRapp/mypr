from django.contrib import admin

# Register your models here.
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from django import forms
from .models import CustomUser,Clubs,Bookings

class CustomUserCreationForm(UserCreationForm):
    class Meta:
        model = CustomUser
        fields = ('username', 'email', 'phone')

class CustomUserChangeForm(UserChangeForm):
    class Meta:
        model = CustomUser
        fields = ('username', 'email', 'phone', 'is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')

class CustomUserAdmin(UserAdmin):
    add_form = CustomUserCreationForm
    form = CustomUserChangeForm
    model = CustomUser
    list_display = ('username', 'email', 'phone', 'is_staff', 'is_active')
    list_filter = ('is_staff', 'is_active', 'groups')
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Personal info', {'fields': ('email', 'phone','first_name','last_name')}),
        ('Permissions', {'fields': ('is_staff', 'is_active', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'phone', 'password1', 'password2', 'is_staff', 'is_active')}
        ),
    )
    search_fields = ('username', 'email', 'phone')
    ordering = ('username',)

admin.site.register(CustomUser, CustomUserAdmin)


# Register the Clubs model
@admin.register(Clubs)
class ClubsAdmin(admin.ModelAdmin):
    list_display = ('club_name', 'phone','location')  # Adjust this based on your model fields
    search_fields = ('club_name', 'phone','location')  # Adjust based on your needs
    list_filter = ('club_name', 'phone','location')  # Adjust based on your needs

@admin.register(Bookings)
class BookingsAdmin(admin.ModelAdmin):
    list_display = ('club', 'booking_type','booked_at')  # Adjust this based on your model fields
    search_fields = ('club', 'booking_type','booked_at')  # Adjust based on your needs
    list_filter = ('club', 'booking_type','booked_at')  # Adjust based on your needs


