# Lystra

**Lystra** is a Flutter mobile app for smart, shared shopping list management. Designed for households and families, it lets you build a personal item catalogue, manage multiple shopping lists, and track your purchase history — all with a clean, tactile UI optimised for one-handed use in a supermarket.

---

## Features

### Free tier
- **Item catalogue** — create reusable items with emoji, category, and unit (kg, un, L, cx, …)
- **Category management** — colour-coded categories to organise your catalogue
- **Unlimited personal lists** — create and manage as many shopping lists as you need
- **List templates** — start a list from a pre-built template (e.g. Campismo) with one tap
- **Shopping mode** — full-screen, immersive mode with items grouped by category; tap to check off
- **Purchase history** — every completed shopping session is saved with date, items, and quantities
- **Item catalogue browser** — browse the built-in catalogue of 52 items across 10 categories and import what you need
- **Skeleton loading & error states** — every screen handles loading, empty, and error states with retry

### Premium tier *(backend logic complete, payments integration pending)*
- **Real-time household sync** — share lists with family members; changes appear instantly for everyone
- **Household management** — create or join a household with an invite code; view all members

---

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 / Dart |
| Backend | Firebase (Auth + Firestore) |
| Push notifications | Firebase Cloud Messaging |
| Navigation | `go_router` |
| Dependency injection | `get_it` |
| Domain models | `freezed` + `json_serializable` |
| Fonts | Inter via `google_fonts` |
| Loading skeletons | `shimmer` |
| Payments *(pending)* | RevenueCat (`purchases_flutter`) |

---

## Architecture

Layered MVVM — strict separation between data, domain, and UI.

```
lib/
├── core/
│   ├── di/            # get_it service locator
│   ├── router/        # go_router + auth guard
│   └── theme/         # Material 3 color scheme, typography, spacing tokens
├── data/
│   ├── models/        # Firestore serialisation (json_serializable)
│   ├── repositories/  # Single source of truth; in-memory cache; offline-safe
│   └── services/      # Firebase wrappers, seed data, list templates, UserState
├── domain/
│   └── models/        # Immutable domain models (freezed)
└── ui/
    ├── core/          # Shared widgets (EmptyStateWidget, SkeletonListTile, …)
    └── features/
        ├── auth/      # Login + Register screens
        ├── catalog/   # Browse built-in item catalogue
        ├── history/   # Purchase history timeline
        ├── items/     # Item & category management
        ├── lists/     # Shopping lists home screen
        ├── profile/   # User profile, catalogue seed, sign-out
        └── shopping/  # Full-screen shopping mode
```

### Key rules
- `ChangeNotifier` ViewModels expose immutable state snapshots
- Views use `ListenableBuilder` — no `setState` for VM-driven state
- Repositories handle caching and data transformation; they are the single Firestore contact point
- `UserState` singleton subscribes internally to Firebase Auth changes; Firebase Auth is the source of truth for identity (email, displayName); Firestore holds app-specific fields (isPremium, householdId)

---

## Domain model

| Model | Description |
|---|---|
| `Item` | Reusable product — name, emoji, category, unit |
| `Category` | Groups items; has a display colour |
| `ShoppingList` | Named list owned by a user; supports sharing |
| `ListEntry` | Join between a list and an item — quantity + checked state |
| `PurchaseRecord` | Snapshot of a completed shopping session |
| `Household` | Group of users who share lists (premium) |
| `AppUser` | Firebase Auth identity + Firestore fields (isPremium, householdId) |

---

## Screens

| Screen | Route | Description |
|---|---|---|
| Login | `/auth/login` | Email + password sign-in with inline validation |
| Register | `/auth/register` | Account creation with display name |
| Lists | `/lists` | Shopping list cards with progress bar and item count |
| Shopping mode | `/lists/:id/shop` | Full-screen, category-grouped check-off |
| Items | `/items` | Catalogue with search, category filter, add/edit/delete |
| History | `/history` | Timeline of past sessions with expandable item breakdown |
| Profile | `/profile` | User info, load base items, sign-out |
| Catalogue browser | *(sheet)* | Browse and import from 52 built-in items |

---

## Getting started

### Prerequisites
- Flutter SDK ≥ 3.4.0
- A Firebase project with Auth (email/password) and Firestore enabled
- `flutterfire` CLI to generate `firebase_options.dart`

### Setup

```bash
# 1. Clone
git clone <repo-url>
cd lystrav2

# 2. Configure Firebase
flutterfire configure

# 3. Install dependencies
flutter pub get

# 4. Generate code (freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# 5. Run
flutter run
```

### Android signing (release)
Create `android/key.properties` (excluded from git):
```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore.jks>
```

---

## Common commands

```bash
# Run
flutter run

# Run all tests
flutter test

# Lint
flutter analyze

# Code generation (one-shot)
dart run build_runner build --delete-conflicting-outputs

# Code generation (watch)
dart run build_runner watch --delete-conflicting-outputs

# Format
dart format lib/ test/
```

---

## Design system

Lystra follows a custom Material 3 design system documented in `CLAUDE.md`:

- **Primary green** `#1B8C5E` — CTAs, FAB, active navigation, check-off accent
- **Secondary indigo** `#3D5A8A` — premium indicators, sync status
- **Font** — Inter (via google_fonts), full M3 type scale
- **Base unit** — 4dp spacing grid
- **Dark mode** — first-class, all tokens defined for both schemes
- **Animations** — check-off bounce, strikethrough draw, skeleton shimmer, FAB collapse on scroll

---

## Security notes

The following files must **never** be committed to git:

- `lib/firebase_options.dart` — regenerate with `flutterfire configure`
- `android/google-services.json`
- `ios/GoogleService-Info.plist`
- `android/key.properties`

All four are listed in `.gitignore`.
