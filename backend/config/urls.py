from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularSwaggerView,
    SpectacularRedocView,
)

urlpatterns = [
    path('admin/', admin.site.urls),

    # OpenAPI 3 Schema & Interactive Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),

    # API v1 Endpoints
    path('api/v1/auth/', include('apps.accounts.urls')),
    path('api/v1/', include('apps.profiles.urls')),
    path('api/v1/currencies/', include('apps.currencies.urls')),
    path('api/v1/exchange-rates/', include('apps.exchange_rates.urls')),
    path('api/v1/categories/', include('apps.categories.urls')),
    path('api/v1/accounts/', include('apps.financial_accounts.urls')),
    path('api/v1/transactions/', include('apps.transactions.urls')),
    path('api/v1/budgets/', include('apps.budgets.urls')),
    path('api/v1/goals/', include('apps.savings_goals.urls')),
    path('api/v1/analytics/', include('apps.analytics.urls')),
    path('api/v1/debts/', include('apps.debts.urls')),
    path('api/v1/subscriptions/', include('apps.subscriptions.urls')),
    path('api/v1/notifications/', include('apps.notifications.urls')),
    path('api/v1/reports/', include('apps.reports.urls')),
    path('api/v1/investments/', include('apps.investments.urls')),
    path('api/v1/billing/', include('apps.billing.urls')),
    path('api/v1/households/', include('apps.households.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
