# MyFinance – Premium Expense Tracker App

## Overview

Build a world-class Flutter personal expense tracker & financial management app that rivals and surpasses Revolut, Monzo, Copilot Money and Apple Wallet in aesthetics, UX, and features.

This is a complete rewrite of the existing blank Flutter project, building a feature-rich multi-screen app with premium animations, glassmorphism, dark/light mode, and a polished design system.

---

## Architecture

We'll use a clean, scalable folder structure:

```
lib/
  main.dart                    # App entry, theme, routing
  core/
    theme/
      app_theme.dart           # Light & Dark ThemeData
      app_colors.dart          # Color constants
      app_text_styles.dart     # Typography system
    models/
      transaction.dart
      budget.dart
      goal.dart
      category.dart
    data/
      mock_data.dart           # Sample data for demo
    utils/
      formatters.dart          # Currency, date formatters
      extensions.dart
  features/
    splash/
      splash_screen.dart
    onboarding/
      onboarding_screen.dart
    auth/
      login_screen.dart
    home/
      home_screen.dart
      widgets/
        balance_card.dart
        spending_ring.dart
        quick_actions.dart
        recent_transactions.dart
        category_grid.dart
    transactions/
      transactions_screen.dart
      add_transaction_screen.dart
    analytics/
      analytics_screen.dart
      widgets/
        line_chart_widget.dart
        pie_chart_widget.dart
        bar_chart_widget.dart
    budgets/
      budgets_screen.dart
    goals/
      goals_screen.dart
    ai_assistant/
      ai_screen.dart
    profile/
      profile_screen.dart
    notifications/
      notifications_screen.dart
  widgets/
    glass_card.dart            # Shared glassmorphism card
    premium_button.dart
    bottom_nav.dart
    animated_fab.dart
```

---

## Dependencies (pubspec.yaml)

| Package | Purpose |
|---|---|
| `google_fonts` | Inter/Outfit typography |
| `fl_chart` | Beautiful interactive charts |
| `provider` | State management |
| `shared_preferences` | Theme persistence |
| `intl` | Currency & date formatting |
| `percent_indicator` | Circular & linear progress |
| `smooth_page_indicator` | Onboarding dots |
| `flutter_animate` | Rich micro-animations |
| `curved_navigation_bar` | Premium bottom nav |
| `glassmorphism` | Frosted glass effects |

---

## Screens

### 1. Splash Screen
- Animated emerald gradient background
- Logo pulse + fade animation
- Auto-navigates to onboarding

### 2. Onboarding (4 pages)
- Full-screen gradient slides
- Custom vector illustrations per slide
- Smooth page transitions + dot indicators
- Skip / Continue buttons

### 3. Login Screen
- Frosted glass card
- Email + Password fields
- Face ID / Fingerprint / Google / Apple sign-in buttons
- Register toggle

### 4. Home Dashboard
- Gradient greeting header with avatar
- Large animated balance card (glassmorphism)
- Spending ring (animated arc)
- AI Financial Health Score widget
- Quick actions grid (Add, Income, Scan, Transfer, Budget)
- Category chips
- Recent transactions list
- Upcoming bills card

### 5. Add Expense
- Large bold amount input (numpad style)
- Category selector (animated grid)
- Merchant, date, payment method, notes fields
- Receipt attach + voice input UI
- Save with confetti animation

### 6. Transactions
- Search bar + filter chips
- Timeline grouped by date
- Income (green) / Expense (red) indicators
- Swipe-to-delete action

### 7. Analytics
- Spending by category (pie/donut chart)
- Income vs Expenses bar chart
- Monthly trend line chart
- Spending heatmap calendar
- AI insights cards

### 8. Budgets
- Circular progress rings per budget
- Remaining amount + alert states
- Add budget bottom sheet

### 9. Goals
- Goal cards with progress bars
- Confetti on completion
- Timeline + savings projections

### 10. AI Assistant
- Chat-style interface
- Pre-built insight cards
- Natural language input

### 11. Notifications
- Grouped notification cards
- Bill reminders, alerts, milestones

### 12. Profile
- User info header
- Dark/Light mode toggle (animated switch)
- Settings list
- Premium badge

---

## Color Palette

| Token | Value |
|---|---|
| Primary (Emerald) | `#10B981` |
| Secondary (Navy) | `#0F172A` |
| Accent (Cyan) | `#06B6D4` |
| Success | `#22C55E` |
| Warning | `#F59E0B` |
| Expense (Coral) | `#EF4444` |
| Income | `#22C55E` |
| Background Light | `#F8FAFC` |
| Background Dark | `#09090B` |

---

## Verification Plan

### Automated
- `flutter analyze` – no lint errors
- `flutter build apk --debug` – successful build

### Manual
- Hot reload to verify all screens render correctly
- Verify dark/light mode switching works
- Check all animations run smoothly
- Verify chart rendering on all analytics views
