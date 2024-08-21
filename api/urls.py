from  django.urls import path
from . import views
from django.contrib.auth import views as auth_views

urlpatterns = [
    path("bookings/", views.BookingCreate.as_view(), name = "bookings"),
    path("bookings/delete/<int:pk>/", views.BookingDelete.as_view(),name="delete-booking"),
    path("user/print/", views.PrintUserView.as_view(),name = "print-user"),
    path("clubs/register/",views.CreateClubView.as_view(),name = "register-club"),
    path("clubs/print/",views.PrintAllClubs.as_view(),name = "print-clubs"),
    path("catalogue/create/", views.CatalogueCreateView.as_view(),name = "catalogue-view"),
    path("clubs/<int:club_id>/catalogue/", views.ClubCatalogueView.as_view(),name = "catalogue-view"),
    path('password-reset/', views.PasswordResetRequestView.as_view(), name='password_reset_request'),
    path('reduce-points/', views.ReducePointsView.as_view(), name='reduce_points'),
    path('reset-password/<uidb64>/<token>/', views.PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('reset_password_page/', views.reset_password_page_view, name='reset_password'),
    path('user/change_photo/',views.UserPhotoUpdateView.as_view(),name= 'change-photo'),
]