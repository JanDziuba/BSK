from django.urls import path
from .views import *


urlpatterns = [
    path('', home_view, name="home_view"),
    path('login/', login_view, name="login_view"),
    path('action/login', login, name="login"),
    path('action/logout', logout, name="logout"),
]
