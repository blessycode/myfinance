# Product foundation

## Phase 1 structure

The existing Flutter project already contains a feature-oriented screen layout. Phase 1 keeps that structure while grouping shared product foundations under `lib/core` and shared components under `lib/widgets`:

```text
lib/
  core/
    brand/       Temporary replaceable product identity
    data/        Demo repository data (currently in-memory)
    models/      Shared financial entities
    providers/   App-level theme state
    theme/       Central light/dark design tokens and themes
    utils/       Currency and date formatting
  features/
    onboarding/  First-run product introduction
    auth/        Demo sign-in and registration experience
    home/        Dashboard and primary navigation shell
    analytics/   Spending views
    budgets/     Budget views
    goals/       Savings goal views
    transactions/ Transaction list and entry
    profile/     Preferences and profile
  widgets/       Reusable cards and buttons
```

## Phase 1 screens

- Splash and onboarding introduce a temporary neutral identity and the core product value.
- Authentication provides a demonstration entry flow; it does not authenticate against a server.
- Home is the navigation shell for Home, Analytics, Budget, Goals, and Profile. A central action sheet opens the transaction entry flow.
- The dashboard, analytics, budget, goals, and profile screens currently read demonstration data from `MockData`.

## Design system

`AppColors` and `AppTheme` are the single source for semantic colors and Material styling. `AppBrand` holds the replaceable display name and mark. Shared card and button components live in `lib/widgets`. The visual direction uses forest green, soft off-white, white surfaces, restrained elevation, and dark mode equivalents.

## Production architecture decisions

The present application predates the requested Riverpod/GoRouter/API/database stack. It currently uses Provider, Navigator, and in-memory demo models. Avoid presenting mock sign-in, social sign-in, notifications, or financial insights as production-connected functionality. The migration path is to introduce repositories and domain calculation services first, then persist through Drift and add API implementations behind repository interfaces. Replace Provider and Navigator with Riverpod and GoRouter as a dedicated migration so routes and state ownership can be changed together. Secure authentication, sync, subscription billing, and market data require backend/provider configuration and are not implemented in this UI phase.

## Delivery phases

1. **Foundation and UI:** branding tokens, responsive themes, onboarding/auth, navigation shell, dashboard.
2. **Core finance:** repository contracts, accounts, transactions, calculations, and offline persistence.
3. **Planning:** analytics, budgets, goals, currencies, recurring items, and debts.
4. **Advanced:** investments, calendar, reminders, statements, and receipt review.
5. **Commercial readiness:** backend, security, sync, entitlements, accessibility, performance, and release validation.
