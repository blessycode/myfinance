from django.urls import path
from .views import ExchangeRateListView, ConvertCurrencyView

urlpatterns = [
    path('', ExchangeRateListView.as_view(), name='exchange-rates-list'),
    path('convert/', ConvertCurrencyView.as_view(), name='exchange-rates-convert'),
]
