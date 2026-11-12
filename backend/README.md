# JIREH Commercial REST API Backend

Production-ready, highly secure personal finance management backend built with Django 5.2 LTS, Django REST Framework, PostgreSQL, SimpleJWT, Celery, and Redis. Features an atomic double-entry ledger engine, multi-currency conversion, real-time analytics, budgeting envelopes, savings goals, and mobile Flutter integrations.

---

## 1. System Architecture

```
backend/
├── config/                  # Project configuration, Celery, WSGI/ASGI, Settings
│   └── settings/            # base.py, development.py, production.py
├── apps/
│   ├── accounts/            # Custom User model (UUID), email auth, password reset, JWT
│   ├── profiles/            # User profile, currency, timezone, biometric preferences
│   ├── currencies/          # Multi-currency models (USD, EUR, GBP, ZAR, ZWG, BWP)
│   ├── exchange_rates/      # Audited rates, snapshots, conversion engine
│   ├── categories/          # Income & Expense categories (system defaults + custom)
│   ├── financial_accounts/  # Multi-account balances (Bank, Mobile Money, Cash, Savings)
│   ├── transactions/        # Double-entry ledger, atomic postings, transfers, reversals
│   ├── budgets/             # Category envelopes, progress calculations, thresholds
│   ├── savings_goals/       # Milestone goals, funding account contributions
│   ├── analytics/           # Executive dashboard metrics, category donuts, trends
│   ├── debts/               # Borrowed/lent obligations, repayment tracking
│   ├── subscriptions/       # Recurring bills, payment frequency, due alerts
│   ├── notifications/       # In-app notifications & alert preferences
│   ├── reports/             # PDF, Excel, and CSV statement generators
│   ├── investments/         # Stocks, ETFs, Crypto portfolio tracking
│   ├── billing/             # Freemium commercial tiers (Free vs Pro), entitlements
│   ├── households/          # Shared financial workspaces & RBAC
│   └── audit/               # Audit trail logging for financial events
├── common/                  # Enterprise wrappers, permissions, idempotency middleware
├── tests/                   # Pytest automated test suite
├── Dockerfile & docker-compose.yml
└── manage.py
```

---

## 2. Quickstart: Docker Compose (Recommended)

To run the complete stack (Django, PostgreSQL, Redis, Celery Worker, Celery Beat):

```bash
cd backend
cp .env.example .env
docker compose up --build
```

Access the interactive API documentation at:
- **Swagger UI:** [http://localhost:8000/api/docs/](http://localhost:8000/api/docs/)
- **ReDoc:** [http://localhost:8000/api/redoc/](http://localhost:8000/api/redoc/)
- **OpenAPI Schema:** [http://localhost:8000/api/schema/](http://localhost:8000/api/schema/)

Seed initial platform defaults:
```bash
docker compose exec backend python manage.py migrate
docker compose exec backend python manage.py seed_financial_system
```

---

## 3. Local Development (Without Docker / Windows)

### Prerequisites
- Python 3.11 or 3.12
- PostgreSQL 14+ (or SQLite fallback for quick local testing)
- Redis (optional for development background jobs)

### Setup Steps on Windows PowerShell

1. **Create and activate a virtual environment:**
   ```powershell
   cd backend
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   ```

2. **Install dependencies:**
   ```powershell
   pip install --upgrade pip
   pip install -r requirements/local.txt
   ```

3. **Configure environment:**
   ```powershell
   Copy-Item .env.example .env
   ```

4. **Run database migrations:**
   ```powershell
   python manage.py migrate
   ```

5. **Seed initial platform defaults (Currencies, Rates, Categories, Plans):**
   ```powershell
   python manage.py seed_financial_system
   ```

6. **Create superuser administrator:**
   ```powershell
   python manage.py createsuperuser
   ```

7. **Launch the development server:**
   ```powershell
   python manage.py runserver 0.0.0.0:8000
   ```

---

## 4. Running Automated Tests

Run the comprehensive test suite with `pytest`:
```bash
pytest
```

To run with coverage:
```bash
pytest --cov=apps --cov-report=term-missing
```

---

## 5. Security & Financial Accounting Principles

1. **Balanced Double-Entry Ledger:** Balance summaries are not client-editable. Financial movements are recorded as debits and credits inside atomic database transactions (`@transaction.atomic`).
2. **Transfer Integrity:** Transfers between accounts credit one account and debit another. They are strictly excluded from income and expense calculations.
3. **Auditability & Reversals:** Transactions are reversed by posting an offsetting inverse movement rather than silently destroying audit records.
4. **Multi-Currency Safety:** Converted balances are computed using recorded exchange rates with historical snapshots. Balances in differing currencies are never directly summed without conversion.
5. **Idempotency Keys:** Duplicate request prevention via `Idempotency-Key` headers on financial mutations.
