from  django.urls import path
from . import views

urlpatterns = [
    path("bookings/", views.BookingCreate.as_view(), name = "bookings"),
    path("bookings/delete/<int:pk>/", views.BookingDelete.as_view(),name="delete-booking"),
    path("user/print/", views.PrintUserView.as_view(),name = "print-user"),
    path("clubs/register/",views.CreateClubView.as_view(),name = "register-club"),
    path("clubs/print/",views.PrintAllClubs.as_view(),name = "print-clubs"),
    path("catalogue/create/", views.CatalogueCreateView.as_view(),name = "catalogue-view"),
    path("clubs/<int:club_id>/catalogue/", views.ClubCatalogueView.as_view(),name = "catalogue-view")
]