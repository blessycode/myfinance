# JIREH

JIREH contains a Flutter mobile client (`lib/`) and a Django REST API (`backend/`). The Django API can be prepared for Vercel using [the deployment guide](backend/VERCEL_DEPLOYMENT.md).

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

With an Android phone connected over USB and USB debugging enabled, install the APK with:

```powershell
flutter install
```

The authentication screens connect to Django registration, login, password reset, and logout endpoints. After login, the app loads the user's profile, accounts, categories, currencies, transactions, budgets, savings goals, subscriptions, notifications, and analytics from the API. Creating or updating these records sends changes to Django and refreshes the displayed data.

The mobile app starts with empty finance data until the API returns the signed-in user's records. The API needs its currencies, exchange rates, and categories initialized before users can record transactions. Configure the API base URL with `--dart-define=API_BASE_URL=...` for each build environment.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
