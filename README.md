# Accountanter (Alpha 0.2)

Accountanter is an offline-first Flutter app for lightweight bookkeeping: clients, invoices, payments, expenses, inventory, recurring invoices, and basic reporting.

## Requirements

- Flutter SDK (stable)

## Run

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

## Activation (Alpha)

The app uses a local activation gate. On first launch you’ll see an activation screen.

- Debug builds accept the key `TEST-LICENSE-KEY`.
- Other builds accept a simple format: `XXXX-XXXX-XXXX-XXXX` (A–Z, 0–9).

Notes:
- Activation is stored locally (the license key is stored as a hash, not plaintext).
- This project is offline-first; there is no server-side verification.

## Settings

- Currency symbol: used across dashboards, lists, and editors.
- Demo Mode: when enabled, the app may seed additional sample categories/vendors to make the UI easier to explore. When disabled, it avoids demo-only seeding.
