from .models import Category, CategoryType

DEFAULT_CATEGORIES = [
    # Income
    ('Salary', CategoryType.INCOME, 'work_rounded', '#10B981'),
    ('Business', CategoryType.INCOME, 'store_rounded', '#059669'),
    ('Freelance', CategoryType.INCOME, 'laptop_mac_rounded', '#00D09C'),
    ('Investments', CategoryType.INCOME, 'trending_up_rounded', '#0D9488'),
    ('Interest', CategoryType.INCOME, 'savings_rounded', '#14B8A6'),
    ('Gifts', CategoryType.INCOME, 'card_giftcard_rounded', '#5EEAD4'),
    ('Other Income', CategoryType.INCOME, 'attach_money_rounded', '#34D399'),

    # Expense
    ('Food and Dining', CategoryType.EXPENSE, 'restaurant_rounded', '#F43F5E'),
    ('Shopping', CategoryType.EXPENSE, 'shopping_bag_rounded', '#F59E0B'),
    ('Transport', CategoryType.EXPENSE, 'directions_car_rounded', '#06B6D4'),
    ('Bills and Utilities', CategoryType.EXPENSE, 'receipt_long_rounded', '#8B5CF6'),
    ('Housing', CategoryType.EXPENSE, 'home_rounded', '#6366F1'),
    ('Healthcare', CategoryType.EXPENSE, 'medical_services_rounded', '#EC4899'),
    ('Education', CategoryType.EXPENSE, 'school_rounded', '#84CC16'),
    ('Entertainment', CategoryType.EXPENSE, 'movie_rounded', '#A855F7'),
    ('Personal Care', CategoryType.EXPENSE, 'spa_rounded', '#F97316'),
    ('Travel', CategoryType.EXPENSE, 'flight_takeoff_rounded', '#38BDF8'),
    ('Subscriptions', CategoryType.EXPENSE, 'subscriptions_rounded', '#64748B'),
    ('Other Expense', CategoryType.EXPENSE, 'more_horiz_rounded', '#94A3B8'),
]

class CategoryService:
    @staticmethod
    def seed_system_categories():
        """Creates global system categories if not already present."""
        created_count = 0
        for name, cat_type, icon, color in DEFAULT_CATEGORIES:
            _, created = Category.objects.get_or_create(
                user=None,
                name=name,
                type=cat_type,
                defaults={'icon': icon, 'color': color, 'is_system': True}
            )
            if created:
                created_count += 1
        return created_count
