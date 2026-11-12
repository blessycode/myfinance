@echo off
set "DATABASE_URL=%DATABASE_URL_UNPOOLED%"
python manage.py migrate
python manage.py seed_financial_system