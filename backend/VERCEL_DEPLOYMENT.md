# Deploy the Django API on Vercel

The Django project lives in `backend/`. In Vercel, import this Git repository and set **Root Directory** to `backend`. Keep the detected Python/Django framework preset and leave the build and output directory settings at their defaults. `requirements.txt` at this directory root includes the production dependencies.

## Environment variables

Set these in Vercel under **Project → Settings → Environment Variables** for Preview and Production as appropriate:

| Name | Value |
| --- | --- |
| `DJANGO_SETTINGS_MODULE` | `config.settings.production` |
| `DJANGO_SECRET_KEY` | A unique, randomly generated secret; never commit it |
| `DJANGO_ALLOWED_HOSTS` | `.vercel.app`, plus any custom API domain you attach |
| `DATABASE_URL` | Neon PostgreSQL connection string; use Neon’s pooled URL and keep it secret |
| `REDIS_URL` | Optional managed Redis connection URL. When omitted, Django stores cache entries in the Neon database. |
| `DJANGO_DEBUG` | `False` |

Registration and password-reset emails use SMTP. Set `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_HOST_USER`, `EMAIL_HOST_PASSWORD`, `EMAIL_USE_TLS`, and a verified `SUPPORT_EMAIL` before relying on email verification or password recovery. Email send failures are suppressed by the current account service.

## First database setup

After the first deployment has its environment variables, run Django migrations once against the Neon database, then seed platform defaults:

```powershell
cd backend
pip install -r requirements.txt
$env:DJANGO_SETTINGS_MODULE = 'config.settings.production'
$env:DJANGO_SECRET_KEY = '<same secret configured in Vercel>'
$env:DJANGO_ALLOWED_HOSTS = '.vercel.app'
$env:DATABASE_URL = '<Neon direct connection URL with sslmode=require>'
python manage.py migrate
python manage.py createcachetable
python manage.py seed_financial_system
```

The production cache uses Redis when `REDIS_URL` is configured. Without Redis, it uses Django's database cache, so run `createcachetable` once after migrations.

Do not save the real values in this file or commit them. The user registration endpoint is available at `/api/v1/auth/register/`; API documentation is at `/api/docs/`.

## Runtime notes

Vercel serves Django as request-driven Functions. The repository also defines Celery worker and beat processes in `docker-compose.yml`; Vercel does not start those processes. Any feature that depends on scheduled or queued tasks needs a separate worker host. The Flutter mobile client uses HTTPS in production and does not need browser CORS access.
