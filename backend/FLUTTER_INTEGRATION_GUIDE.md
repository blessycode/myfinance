# Flutter Integration Guide & API Contract

This document provides the complete API contract, payload schemas, and client architecture for integrating the JIREH Flutter application with its Django REST Framework backend.

---

## 1. Environment & Base URL Configuration

In Flutter, configure your API base URL dynamically based on execution platform:

| Target Platform | Base URL |
| :--- | :--- |
| **Android Emulator** | `http://10.0.2.2:8000/api/v1` |
| **iOS Simulator** | `http://127.0.0.1:8000/api/v1` |
| **Physical Device (LAN)** | `http://<YOUR_COMPUTER_LOCAL_IP>:8000/api/v1` |
| **Production Cloud** | `https://api.yourdomain.com/api/v1` |

### Recommended Dio Client Setup (Flutter)
```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          const storage = FlutterSecureStorage();
          final token = await storage.read(key: 'jwt_access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
}
```

---

## 2. Standard API Response Envelope

Every endpoint wraps its payload in the enterprise response envelope:

```json
{
  "success": true,
  "message": "Request completed successfully",
  "data": { ... }
}
```

Error responses:
```json
{
  "success": false,
  "message": "Validation or processing error occurred",
  "errors": {
    "amount": ["Ensure this value is greater than 0.00."]
  },
  "status_code": 400
}
```

---

## 3. Endpoints & Sample Payloads

### 3.1 Authentication

#### POST `/api/v1/auth/register/`
**Request:**
```json
{
  "email": "ayesha@example.com",
  "password": "SecurePassword123!",
  "first_name": "Ayesha",
  "last_name": "Khan",
  "phone_number": "+15550192834",
  "preferred_currency": "USD"
}
```
**Response (201 Created):**
```json
{
  "success": true,
  "message": "Account registered successfully",
  "data": {
    "tokens": {
      "access": "eyJhbGciOiJIUzI1NiIsIn...",
      "refresh": "eyJhbGciOiJIUzI1NiIsIn...",
      "user": {
        "id": "e5b8d2b9-1234-4567-89ab-cdef01234567",
        "email": "ayesha@example.com",
        "first_name": "Ayesha",
        "last_name": "Khan",
        "full_name": "Ayesha Khan"
      }
    },
    "user": {
      "id": "e5b8d2b9-1234-4567-89ab-cdef01234567",
      "email": "ayesha@example.com",
      "first_name": "Ayesha",
      "last_name": "Khan",
      "full_name": "Ayesha Khan",
      "phone_number": "+15550192834",
      "is_verified": false
    }
  }
}
```

#### POST `/api/v1/auth/login/`
**Request:**
```json
{
  "email": "ayesha@example.com",
  "password": "SecurePassword123!"
}
```

---

### 3.2 Financial Accounts (Maps to Flutter `AccountSummary`)

#### GET `/api/v1/accounts/`
**Response (200 OK):**
```json
{
  "success": true,
  "message": "Request completed successfully",
  "data": {
    "count": 3,
    "results": [
      {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "name": "Everyday Checking",
        "account_type": "bank",
        "currency": "USD",
        "opening_balance": "4000.50",
        "current_balance": "4000.50",
        "institution_name": "Barclays",
        "color": "#059669",
        "icon": "account_balance_rounded",
        "is_active": true
      },
      {
        "id": "4fa85f64-5717-4562-b3fc-2c963f66afa7",
        "name": "Reserve Savings",
        "account_type": "savings",
        "currency": "USD",
        "opening_balance": "18600.00",
        "current_balance": "18600.00",
        "institution_name": "Standard Bank",
        "color": "#10B981",
        "icon": "savings_rounded",
        "is_active": true
      }
    ]
  }
}
```

#### POST `/api/v1/accounts/`
**Request:**
```json
{
  "name": "EcoCash Mobile Wallet",
  "account_type": "mobile_money",
  "currency": "ZWG",
  "opening_balance": "12500.00",
  "institution_name": "EcoCash Zimbabwe",
  "color": "#00D09C",
  "icon": "phone_android_rounded"
}
```

---

### 3.3 Transactions & Transfers (Maps to Flutter `Transaction`)

#### POST `/api/v1/transactions/`
**Request:**
```json
{
  "account": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "transaction_type": "expense",
  "category": "8ba85f64-5717-4562-b3fc-2c963f66afa8",
  "amount": "8.50",
  "currency": "USD",
  "description": "Starbucks Coffee",
  "merchant": "Starbucks",
  "transaction_date": "2026-11-11",
  "payment_method": "credit_card",
  "notes": "Morning espresso"
}
```

#### POST `/api/v1/transactions/transfer/`
**Request:**
```json
{
  "from_account": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "to_account": "4fa85f64-5717-4562-b3fc-2c963f66afa7",
  "amount": "500.00",
  "description": "Monthly savings allocation",
  "transaction_date": "2026-11-11"
}
```
*Note: Transfers are balanced double-entry movements that update ledger balances without inflating income or expense totals.*

---

### 3.4 Multi-Currency & Live Conversions

#### POST `/api/v1/exchange-rates/convert/`
**Request:**
```json
{
  "amount": "1000.00",
  "from_currency": "USD",
  "to_currency": "ZAR"
}
```
**Response (200 OK):**
```json
{
  "success": true,
  "message": "Request completed successfully",
  "data": {
    "original_amount": "1000.00",
    "from_currency": "USD",
    "converted_amount": "18181.82",
    "to_currency": "ZAR",
    "exchange_rate": "18.181818",
    "valuation_date": "2026-11-11T13:30:00Z"
  }
}
```

---

### 3.5 Executive Analytics & Dashboard

#### GET `/api/v1/analytics/dashboard/`
Powers the Flutter `FinancialBalanceCard` and multi-currency holdings strip directly:
**Response (200 OK):**
```json
{
  "success": true,
  "message": "Request completed successfully",
  "data": {
    "total_balance": "24750.80",
    "currency": "USD",
    "monthly_income": "6000.00",
    "monthly_expense": "1450.75",
    "net_savings": "4549.25",
    "savings_rate": 0.7582,
    "accounts_count": 3,
    "holdings_by_currency": [
      { "currency": "USD", "amount": "22600.50" },
      { "currency": "EUR", "amount": "1200.00" },
      { "currency": "ZWG", "amount": "25000.00" }
    ],
    "insights": [
      "You have preserved USD 4,549.25 in net savings this month.",
      "Food and Dining is your largest expenditure at USD 458.50 (31.6%)"
    ]
  }
}
```

#### GET `/api/v1/analytics/spending-breakdown/?days=30`
Powers the Flutter FL Chart donut chart directly:
**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    { "category_name": "Food & Dining", "amount": "458.50", "percentage": 31.6, "color": "#F43F5E" },
    { "category_name": "Shopping", "amount": "388.99", "percentage": 26.8, "color": "#F59E0B" },
    { "category_name": "Transport", "amount": "183.30", "percentage": 12.6, "color": "#06B6D4" },
    { "category_name": "Health", "amount": "129.00", "percentage": 8.9, "color": "#EC4899" }
  ]
}
```

---

### 3.6 Budgets (Maps to Flutter `Budget`)

#### GET `/api/v1/budgets/`
**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "id": "7fa85f64-5717-4562-b3fc-2c963f66afa9",
        "name": "Food & Groceries",
        "amount": "500.00",
        "currency": "USD",
        "spent": "458.50",
        "remaining": "41.50",
        "percentage": 0.917,
        "is_exceeded": false,
        "is_warning": true,
        "color": "#10B981"
      }
    ]
  }
}
```

---

### 3.7 Savings Goals (Maps to Flutter `Goal`)

#### POST `/api/v1/goals/{id}/contributions/`
**Request:**
```json
{
  "from_account": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "amount": "200.00",
  "note": "Bi-weekly paycheck contribution"
}
```

---

### 3.8 Subscriptions & Recurring Bills (Maps to Flutter `Bill`)

#### GET `/api/v1/subscriptions/`
**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "id": "1fa85f64-5717-4562-b3fc-2c963f66af10",
        "name": "Netflix 4K",
        "merchant": "Netflix",
        "amount": "19.99",
        "currency": "USD",
        "frequency": "monthly",
        "next_due_date": "2026-11-15",
        "days_until_due": 4,
        "is_due_soon": false,
        "is_overdue": false
      }
    ]
  }
}
```

---

### 3.9 Reports & Export

#### GET `/api/v1/reports/export/?format=pdf`
#### GET `/api/v1/reports/export/?format=excel`
#### GET `/api/v1/reports/export/?format=csv`
Returns binary stream with authenticated download headers.
