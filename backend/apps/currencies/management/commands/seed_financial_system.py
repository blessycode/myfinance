from decimal import Decimal
from django.core.management.base import BaseCommand
from apps.currencies.models import Currency
from apps.exchange_rates.models import ExchangeRate
from apps.categories.services import CategoryService
from apps.billing.models import SubscriptionPlan, PlanTier

class Command(BaseCommand):
    help = 'Seeds standard currencies, initial exchange rates, categories, and subscription plans.'

    def handle(self, *args, **options):
        self.stdout.write("Seeding currencies...")
        currencies = [
            ('USD', 'United States Dollar', '$', 2),
            ('EUR', 'Euro', '€', 2),
            ('GBP', 'British Pound Sterling', '£', 2),
            ('ZAR', 'South African Rand', 'R', 2),
            ('ZWG', 'Zimbabwe Gold', 'ZiG', 2),
            ('BWP', 'Botswana Pula', 'P', 2),
        ]
        for code, name, symbol, precision in currencies:
            Currency.objects.get_or_create(
                code=code,
                defaults={'name': name, 'symbol': symbol, 'decimal_precision': precision, 'is_active': True}
            )

        self.stdout.write("Seeding baseline exchange rates against USD...")
        usd = Currency.objects.get(code='USD')
        rates = [
            ('EUR', Decimal('0.917431')),
            ('GBP', Decimal('0.781250')),
            ('ZAR', Decimal('18.181818')),
            ('ZWG', Decimal('26.315789')),
            ('BWP', Decimal('13.513514')),
        ]
        for target_code, rate_val in rates:
            target_curr = Currency.objects.get(code=target_code)
            ExchangeRate.objects.get_or_create(
                base_currency=usd,
                target_currency=target_curr,
                rate=rate_val,
                defaults={'source': 'official_central_bank_benchmark'}
            )

        self.stdout.write("Seeding default system categories...")
        cat_count = CategoryService.seed_system_categories()

        self.stdout.write("Seeding billing plans...")
        SubscriptionPlan.objects.get_or_create(
            tier=PlanTier.FREE,
            defaults={
                'name': 'Starter Free',
                'price': Decimal('0.00'),
                'features': ['Up to 5 accounts', 'Basic analytics', 'Standard budgeting']
            }
        )
        SubscriptionPlan.objects.get_or_create(
            tier=PlanTier.PRO,
            defaults={
                'name': 'Pro Finance Suite',
                'price': Decimal('9.99'),
                'features': ['Unlimited accounts', 'Advanced analytics & trends', 'PDF & Excel exports', 'Multi-currency live ledger']
            }
        )

        self.stdout.write(self.style.SUCCESS("Successfully seeded financial platform defaults!"))
