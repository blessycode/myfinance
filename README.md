# JIREH — Personal Finance, Made Clear

JIREH is a cross-platform personal finance app built with Flutter and Django REST Framework. It brings everyday money management into one place, with multi-currency accounts, transactions, budgets, savings goals, recurring bills, debts, notifications, and analytics.

## Portfolio overview

JIREH demonstrates a full-stack mobile product: a Flutter client with light and dark themes, reusable UI components, secure token-based sign-in, and a Django API that stores and serves each user's financial records. The dashboard summarizes balances and recent activity, while dedicated screens support analytics, budgets, goals, and account settings.

### Highlights

- Track income, expenses, and transfers across multiple accounts and currencies.
- Set budgets and savings goals, and track recurring bills and debts.
- Review spending and account activity in a visual dashboard and analytics views.
- Keep a sign-in session across app restarts with access and refresh tokens in secure device storage.
- Optionally lock app launch with the phone's biometrics or screen-lock passcode.
- Switch between light and dark themes.

## Screenshots

Add real device screenshots to `screenshots/` and link them here. Capture the dashboard with sample data, then analytics, budgets, goals, and the device-unlock setting. Avoid including real account details or personal financial data.

| Dashboard | Analytics | Budgets |
| --- | --- | --- |
| _Add `screenshots/dashboard.png`_ | _Add `screenshots/analytics.png`_ | _Add `screenshots/budgets.png`_ |

| Savings goals | Security settings | Dark theme |
| --- | --- | --- |
| _Add `screenshots/goals.png`_ | _Add `screenshots/security.png`_ | _Add `screenshots/dark-theme.png`_ |

## Tech stack

- **Mobile:** Flutter, Dart, Provider
- **API:** Django REST Framework
- **Security:** JWT access/refresh tokens, Flutter Secure Storage, on-device authentication via `local_auth`
- **Visualization:** `fl_chart`

## Run the Flutter app against the local API

Start Django on `0.0.0.0:8000`, then run Flutter on an Android emulator:

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

For a physical phone during local development, use your computer's LAN IP instead of `10.0.2.2`. For a production Android build, provide the deployed HTTPS API URL:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR-VERCEL-HOST/api/v1
```

With an Android phone connected over USB and USB debugging enabled, install the APK with `flutter install`.

The authentication screens connect to Django registration, login, password reset, and logout endpoints. After login, the app loads the user's profile, accounts, categories, currencies, transactions, budgets, savings goals, subscriptions, notifications, and analytics from the API. Creating or updating these records sends changes to Django and refreshes the displayed data. The app restores saved tokens on launch; if the refresh token has expired or is rejected, the user must sign in again. Device unlock is an optional local app lock and does not replace account sign-in.

The API needs its currencies, exchange rates, and categories initialized before users can record transactions. Configure the API base URL with `--dart-define=API_BASE_URL=...` for each build environment. The Django API can be prepared for Vercel using [the deployment guide](backend/VERCEL_DEPLOYMENT.md).
