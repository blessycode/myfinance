from decimal import Decimal
from datetime import timedelta
from django.utils import timezone
from django.db.models import Sum, Count, Q
from apps.transactions.models import Transaction, TransactionType
from apps.financial_accounts.models import FinancialAccount
from apps.categories.models import Category
from apps.exchange_rates.services import CurrencyConversionService
from common.utilities.money import round_money

class AnalyticsService:
    @classmethod
    def get_dashboard_summary(cls, user) -> dict:
        pref_curr = user.profile.preferred_currency if hasattr(user, 'profile') else 'USD'
        now = timezone.now()

        # 1. Total Net Balance across all active accounts converted to preferred currency
        accounts = FinancialAccount.objects.filter(user=user, is_active=True, is_archived=False)
        total_balance = Decimal('0.00')
        holdings_by_currency = {}

        for acc in accounts:
            c = acc.currency
            holdings_by_currency[c] = holdings_by_currency.get(c, Decimal('0.00')) + acc.current_balance
            converted, _ = CurrencyConversionService.convert(acc.current_balance, c, pref_curr)
            total_balance += converted

        # 2. Current Month Income & Expense (Excluding transfers)
        current_month_trxs = Transaction.objects.filter(
            user=user,
            transaction_date__year=now.year,
            transaction_date__month=now.month,
            is_reversed=False
        ).exclude(transaction_type=TransactionType.TRANSFER)

        monthly_income = Decimal('0.00')
        monthly_expense = Decimal('0.00')

        for t in current_month_trxs:
            converted, _ = CurrencyConversionService.convert(t.amount, t.currency, pref_curr)
            if t.transaction_type == TransactionType.INCOME:
                monthly_income += converted
            elif t.transaction_type == TransactionType.EXPENSE:
                monthly_expense += converted

        net_savings = monthly_income - monthly_expense
        savings_rate = (
            float((net_savings / monthly_income).quantize(Decimal('0.0001')))
            if monthly_income > Decimal('0.00') and net_savings > Decimal('0.00')
            else 0.0
        )

        # 3. Dynamic Calculated Smart Insights
        insights = []
        if monthly_income > Decimal('0.00'):
            insights.append(f"You have preserved {pref_curr} {net_savings:,.2f} in net savings this month.")
        if monthly_expense > Decimal('0.00'):
            # find largest expense category
            cat_breakdown = cls.get_spending_breakdown(user, days=30)
            if cat_breakdown:
                top_cat = cat_breakdown[0]
                insights.append(f"{top_cat['category_name']} is your largest expenditure at {pref_curr} {top_cat['amount']:,.2f} ({top_cat['percentage']}%)")
        if not insights:
            insights.append("Record your first transactions to generate live personalized spending intelligence.")

        return {
            'total_balance': round_money(total_balance),
            'currency': pref_curr,
            'monthly_income': round_money(monthly_income),
            'monthly_expense': round_money(monthly_expense),
            'net_savings': round_money(net_savings),
            'savings_rate': savings_rate,
            'accounts_count': accounts.count(),
            'holdings_by_currency': [
                {'currency': k, 'amount': round_money(v)} for k, v in holdings_by_currency.items()
            ],
            'insights': insights,
            'as_of': now
        }

    @classmethod
    def get_spending_breakdown(cls, user, days: int = 30) -> list[dict]:
        pref_curr = user.profile.preferred_currency if hasattr(user, 'profile') else 'USD'
        start_date = timezone.now().date() - timedelta(days=days)

        expenses = Transaction.objects.filter(
            user=user,
            transaction_type=TransactionType.EXPENSE,
            transaction_date__gte=start_date,
            is_reversed=False
        ).select_related('category')

        cat_totals = {}
        total_spending = Decimal('0.00')

        for e in expenses:
            converted, _ = CurrencyConversionService.convert(e.amount, e.currency, pref_curr)
            total_spending += converted
            cat_id = str(e.category_id) if e.category else 'uncategorized'
            cat_name = e.category.name if e.category else 'Uncategorized'
            cat_color = e.category.color if e.category else '#94A3B8'
            cat_icon = e.category.icon if e.category else 'more_horiz'

            if cat_id not in cat_totals:
                cat_totals[cat_id] = {
                    'category_id': cat_id,
                    'category_name': cat_name,
                    'color': cat_color,
                    'icon': cat_icon,
                    'amount': Decimal('0.00')
                }
            cat_totals[cat_id]['amount'] += converted

        result = []
        for cat in cat_totals.values():
            amount = cat['amount']
            pct = round(float(amount / total_spending) * 100, 1) if total_spending > Decimal('0.00') else 0.0
            result.append({
                'category_id': cat['category_id'],
                'category_name': cat['category_name'],
                'color': cat['color'],
                'icon': cat['icon'],
                'amount': round_money(amount),
                'percentage': pct
            })

        result.sort(key=lambda x: x['amount'], reverse=True)
        return result

    @classmethod
    def get_spending_trends(cls, user, months: int = 6) -> list[dict]:
        pref_curr = user.profile.preferred_currency if hasattr(user, 'profile') else 'USD'
        now = timezone.now().date()
        trends = []

        for i in range(months - 1, -1, -1):
            target_date = (now.replace(day=1) - timedelta(days=i * 28)).replace(day=1)
            y, m = target_date.year, target_date.month

            trxs = Transaction.objects.filter(
                user=user,
                transaction_date__year=y,
                transaction_date__month=m,
                is_reversed=False
            ).exclude(transaction_type=TransactionType.TRANSFER)

            inc = Decimal('0.00')
            exp = Decimal('0.00')

            for t in trxs:
                converted, _ = CurrencyConversionService.convert(t.amount, t.currency, pref_curr)
                if t.transaction_type == TransactionType.INCOME:
                    inc += converted
                elif t.transaction_type == TransactionType.EXPENSE:
                    exp += converted

            month_label = target_date.strftime('%b')
            trends.append({
                'period': f"{y}-{m:02d}",
                'label': month_label,
                'income': round_money(inc),
                'expense': round_money(exp),
                'net': round_money(inc - exp),
                'currency': pref_curr
            })

        return trends
