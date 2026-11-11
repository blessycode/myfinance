# Personal finance application delivery plan

The product brief defines five delivery phases. This plan records the actual status of the existing Flutter project and avoids describing mock behavior as production functionality.

## Phase 1 — Foundation and UI

**In progress**

- Shared forest green and warm neutral design tokens, Material light and dark themes, and configurable temporary brand identity.
- Four-page onboarding with skip, continue, and get started actions.
- Responsive sign-in and registration presentation with field validation, password visibility, and a demo-mode notice.
- Primary navigation for Home, Analytics, Budget, Goals, and Profile, with a central quick-action sheet.
- Dashboard with time-based greeting, balance visibility control, account overview, and recent transaction access.
- Shared card treatment aligned to a restrained financial product.

**Known limitations:** authentication, account balances, transactions, insights, and account summaries are demonstration data. Forgot password is a UI-only demo response. The repository still uses Provider and Navigator rather than the requested Riverpod and GoRouter. No persistence or backend integration is present.

## Phase 2 — Core finance

- Define repository interfaces and replace direct `MockData` reads with repository providers.
- Implement account and transaction create, update, search, filtering, deletion, and balance calculation services.
- Add structured offline persistence and a migration strategy.
- Preserve transfer semantics and original transaction currencies.

## Phase 3 — Financial planning

- Implement analytics, budgets, goals, exchange-rate-aware multi-currency views, recurring items, and debt records.
- Add calculation services and unit tests for financial rules.

## Phase 4 — Advanced functionality

- Add investment tracking, calendar events, local reminders, reports and exports, and receipt review flows.

## Phase 5 — Commercial readiness

- Integrate backend authentication, user-isolated APIs, encrypted sync, security controls, subscription entitlements, accessibility review, performance work, and store release validation.

## Phase exit criteria

At each phase boundary, run static analysis and the relevant automated tests, fix regressions, document mock versus connected behavior, and record remaining work before starting the next phase.
