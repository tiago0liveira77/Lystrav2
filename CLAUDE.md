# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Lystra** is a Flutter/Dart mobile SaaS app for shared shopping list management. Core features:
- Item and category management (create once, reuse across lists)
- Shopping lists with per-item quantities, real-time check-off while shopping
- Purchase history tracking (last bought date + quantities)
- Family/household list sync (real-time collaboration)
- Free and premium tiers (sync is premium)

## Common Commands

```bash
# Run the app
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/file_test.dart

# Lint / analyze
flutter analyze

# Generate code (freezed, json_serializable, etc.)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs

# Format code
dart format lib/ test/
```

## Architecture

Follow the layered MVVM architecture defined in `.agents/skills/flutter-apply-architecture-best-practices/SKILL.md`. The skill file is authoritative — re-read it when implementing any new feature.

### Layer summary

```
lib/
├── data/
│   ├── models/         # API/DB models (raw, serializable)
│   ├── repositories/   # Single source of truth; returns domain models
│   └── services/       # Stateless wrappers: Firestore, local DB, auth, etc.
├── domain/
│   ├── models/         # Immutable domain models (freezed)
│   └── use_cases/      # Complex cross-repository logic only
└── ui/
    ├── core/           # Shared widgets, theme, typography, router
    └── features/
        └── [feature]/
            ├── view_models/   # ChangeNotifier; injected repos/use-cases
            └── views/         # Stateless widgets; ListenableBuilder for state
```

### Key rules
- ViewModels extend `ChangeNotifier`; expose immutable state snapshots.
- Views use `ListenableBuilder` (not `setState`) to react to ViewModel changes.
- Repositories handle caching, offline sync, and data transformation.
- Use Cases are optional — only add them when logic clutters the ViewModel or must be shared across multiple ViewModels.
- Domain models are immutable; use `freezed`.

## Domain Concepts

| Concept | Description |
|---|---|
| `Item` | A reusable product (name, category, unit). Created once. |
| `Category` | Groups items (e.g., Dairy, Produce). |
| `ShoppingList` | A named list owned by a household/user. Supports sharing. |
| `ListEntry` | Join between a `ShoppingList` and an `Item`, with quantity and `checked` state. |
| `PurchaseRecord` | Historical snapshot of a completed list (date + items + quantities). |
| `Household` | Group of users who share lists (premium feature). |

## Feature Tiers

**Free:** item/category management, unlimited personal lists, purchase history.  
**Premium:** real-time household sync, list sharing with family members (consider: smart suggestions based on history, recurring list templates).

## Dependency Injection

Use `provider` or `get_it` (decide and commit at project start). Register Services → Repositories → ViewModels in a top-level DI setup. ViewModels receive repos via constructor injection.

## Workflow for New Features

Follow the 8-step checklist in the architecture skill file:
1. Define domain models (freezed)
2. Implement Services
3. Implement Repositories
4. Add Use Cases only if needed
5. Implement ViewModel
6. Implement View
7. Register in DI
8. Write + run unit tests for ViewModel and Repository

---

## UI/UX Design System

> This section is authoritative for all visual and interaction decisions. Claude Design agents should consume this section directly.

### Design Philosophy

Lystra is a **task-first, frictionless** shopping experience. The UI must feel fast and tactile — users are in a supermarket with one hand occupied. Every interaction should be completable with a single thumb tap. The visual language is **fresh, modern, and calm**: clean surfaces, generous whitespace, and purposeful micro-animations that provide feedback without distraction. Dark mode is a first-class citizen, not an afterthought.

---

### Color System

Lystra uses a **dual-brand palette**: a primary green anchored in nature/freshness and a secondary indigo for premium and informational surfaces. All colors are defined as Material 3 color tokens.

#### Light Mode

| Token | Hex | Usage |
|---|---|---|
| `primary` | `#1B8C5E` | CTAs, FAB, active nav, checked item accent |
| `onPrimary` | `#FFFFFF` | Text/icons on primary |
| `primaryContainer` | `#C2F0DC` | Chips, soft badges, selected row tint |
| `onPrimaryContainer` | `#00361F` | Text inside primaryContainer |
| `secondary` | `#3D5A8A` | Premium badges, sync indicators, links |
| `onSecondary` | `#FFFFFF` | Text/icons on secondary |
| `secondaryContainer` | `#D9E3FF` | Premium feature highlights |
| `tertiary` | `#F59E0B` | Quantity badges, warnings |
| `error` | `#DC2626` | Destructive actions, validation |
| `surface` | `#F6FAF8` | Screen backgrounds |
| `surfaceVariant` | `#E8F0EC` | Card backgrounds, input fills |
| `onSurface` | `#0D1F17` | Primary body text |
| `onSurfaceVariant` | `#4A6358` | Secondary text, placeholders, metadata |
| `outline` | `#A0B4AC` | Dividers, inactive borders |
| `outlineVariant` | `#D0DDD8` | Subtle separators |
| `inverseSurface` | `#1E3329` | Snackbar background |
| `inverseOnSurface` | `#EAF3EE` | Snackbar text |

#### Dark Mode

| Token | Hex | Usage |
|---|---|---|
| `primary` | `#5ECFA0` | CTAs, active elements |
| `onPrimary` | `#00391E` | Text on primary |
| `primaryContainer` | `#006640` | Elevated primary surfaces |
| `onPrimaryContainer` | `#A0EBCA` | Text inside primaryContainer |
| `secondary` | `#A8C0FF` | Premium indicators |
| `surface` | `#0C1A14` | Screen background |
| `surfaceVariant` | `#162A20` | Card / input background |
| `onSurface` | `#DBF0E7` | Primary body text |
| `onSurfaceVariant` | `#8BADA0` | Secondary text |
| `outline` | `#4A6358` | Dividers |

#### Semantic Usage Rules
- Checked/completed items: text gets `onSurfaceVariant` + strikethrough; row tinted with `primaryContainer` at 40% opacity.
- Premium-gated features: `secondaryContainer` background + lock icon in `secondary`.
- Destructive (delete): always `error` color; never use primary for destructive actions.
- Quantity badge: pill in `tertiary` background with `onTertiary` text.

---

### Typography

Font family: **Inter** (via `google_fonts`). Use Material 3 type scale — no custom sizes outside these tokens.

| Token | Size | Weight | Line Height | Usage |
|---|---|---|---|---|
| `displaySmall` | 36sp | 400 | 44sp | Empty state headlines |
| `headlineMedium` | 28sp | 600 | 36sp | Screen titles (e.g., list name) |
| `headlineSmall` | 24sp | 600 | 32sp | Section headers |
| `titleLarge` | 22sp | 600 | 28sp | Card titles, modal headers |
| `titleMedium` | 16sp | 600 | 24sp | Item names in list |
| `titleSmall` | 14sp | 600 | 20sp | Category label chips |
| `bodyLarge` | 16sp | 400 | 24sp | Body text, descriptions |
| `bodyMedium` | 14sp | 400 | 20sp | Secondary info, metadata |
| `bodySmall` | 12sp | 400 | 16sp | Timestamps, helper text |
| `labelLarge` | 14sp | 600 | 20sp | Buttons, nav labels |
| `labelSmall` | 11sp | 500 | 16sp | Quantity badges, tags |

---

### Spacing & Shape System

**Base unit:** 4dp. All spacing is a multiple of 4.

| Token | Value | Usage |
|---|---|---|
| `spacing.xs` | 4dp | Icon padding, tight gaps |
| `spacing.sm` | 8dp | Chip padding, inline gaps |
| `spacing.md` | 16dp | Standard horizontal padding |
| `spacing.lg` | 24dp | Section gaps, card padding |
| `spacing.xl` | 32dp | Hero sections, empty states |
| `spacing.xxl` | 48dp | FAB bottom clearance |

**Border radius:**

| Token | Value | Usage |
|---|---|---|
| `radius.sm` | 8dp | Chips, small badges |
| `radius.md` | 12dp | Input fields, small cards |
| `radius.lg` | 16dp | List item cards, bottom sheet handles |
| `radius.xl` | 24dp | Large cards, modals |
| `radius.full` | 999dp | FAB, avatar, pill badges |

---

### Elevation & Shadows

Use Material 3 tonal elevation (color tinting over shadows). Reserve drop shadows for overlapping surfaces only.

| Level | Usage |
|---|---|
| 0 | Flat backgrounds, list rows |
| 1 | Cards at rest |
| 2 | Focused/hovered cards |
| 3 | FAB, navigation bar |
| 4 | Modal bottom sheets |
| 5 | Dialogs, dropdowns |

---

### Component Patterns

#### List Item Row (core component)
- Height: **64dp** (with quantity badge) / **56dp** (without)
- Left: category color dot (8dp circle) + item icon or emoji
- Center: `titleMedium` item name + `bodySmall` category name below
- Right: quantity pill (`labelSmall`, `tertiary` background) + checkbox
- Checked state: row fades to 60% opacity, item name gets strikethrough, left dot turns `primary`
- Swipe right: reveal green "Add quantity" action
- Swipe left: reveal red "Remove from list" action (with haptic feedback)

#### Floating Action Button
- Extended FAB on empty/idle state: icon + label ("Add item")
- Collapses to standard FAB when list has items (scroll down triggers collapse)
- Color: `primary`; icon: `add` or context-specific

#### Shopping List Card (on Home screen)
- Rounded card (`radius.xl`), elevation 1
- Header: list name (`titleLarge`) + member avatars (stacked, max 3 + overflow count)
- Progress bar: thin, `primary` color, shows checked/total items ratio
- Footer: `bodySmall` — item count + last updated timestamp
- Premium lists: subtle `secondary` shimmer border

#### Category Chip
- Filled chip with category color at 15% opacity background + full-color leading dot
- Shape: `radius.full`
- `titleSmall` text in `onSurface`

#### Empty State
- Centered illustration (SVG, 200dp wide) + `displaySmall` headline + `bodyLarge` subtext + CTA button
- Each screen has a unique empty state; never show a blank screen

#### Bottom Sheet (add/edit)
- Drag handle: 32dp × 4dp, `outlineVariant`, centered
- Max height: 90% of screen
- Input fields: filled style, `surfaceVariant` fill, `radius.md`
- Confirm button: full-width, `primary`, at bottom with `spacing.md` horizontal padding

---

### Animation Specifications

All animations use **Material Motion** principles: shared-axis for navigation, container transform for detail views, fade-through for tab switches.

#### Check-off Animation (highest priority — must feel satisfying)
- **Trigger:** tap checkbox or row
- Checkbox: scale bounce `1.0 → 1.3 → 1.0` over 280ms, `Curves.elasticOut`
- Checkmark draw: stroke path animation, 200ms, `Curves.easeOut`
- Row: background tint fades in (`primaryContainer` at 40%) over 180ms
- Strikethrough: line draws left-to-right, 200ms, `Curves.easeInOut`, delayed 80ms after check
- Text opacity: fades to 60% over 200ms
- Haptic: `HapticFeedback.mediumImpact()` on completion

#### Item Add Animation
- New row slides in from bottom with fade, 250ms, `Curves.easeOutCubic`
- If list was empty, empty-state fades out first (150ms), then row slides in

#### Item Remove Animation (swipe or delete)
- Row slides out to the triggering direction, 220ms, `Curves.easeInCubic`
- Remaining rows collapse gap: height animation, 200ms, `Curves.easeOutQuart`

#### FAB Collapse (on scroll)
- Extended → compact: label fades out (120ms), container width animates (200ms, `Curves.easeInOut`)
- Compact → extended: reverse, triggered when scroll reaches top

#### List Progress Bar
- Animates width on every check/uncheck, 350ms, `Curves.easeOutCubic`
- At 100%: brief green pulse glow + confetti burst (lottie, 1.5s, non-blocking)

#### Screen Transitions
- Push navigation (list → detail): shared axis horizontal, 300ms
- Modal/bottom sheet: slide up + fade, 280ms, `Curves.easeOutCubic`
- Tab switch: fade-through, 200ms

#### Skeleton Loading
- Use shimmer (`shimmer` package) on list cards and item rows while data loads
- Never show a spinner alone on a screen that has a known shape

---

### Navigation Structure

Bottom navigation bar (Material 3 `NavigationBar`) with 4 destinations:

| Index | Icon (outlined / filled) | Label | Badge |
|---|---|---|---|
| 0 | `shopping_cart_outlined` / `shopping_cart` | Lists | Active list indicator dot |
| 1 | `inventory_2_outlined` / `inventory_2` | Items | — |
| 2 | `history_outlined` / `history` | History | — |
| 3 | `person_outlined` / `person` | Profile | Premium crown if subscribed |

- Active destination: icon switches to filled, `primary` color tint on indicator pill
- Transition between tabs: fade-through animation

---

### Key Screen Descriptions

#### Home — Lists Screen
- `SliverAppBar` with large title ("My Lists"), collapses on scroll
- Grid (2 columns, 8dp gap) of Shopping List Cards on tablet; single column list on phone
- FAB: "New List"
- Pull-to-refresh triggers sync (premium only; free shows "Sync is a premium feature" tooltip)

#### Shopping Mode (active list detail)
- Full-screen, immersive — hides bottom nav
- Sticky header: list name + progress bar + member avatars
- Items grouped by category (collapsible `SliverList` sections)
- Category header: colored strip with category name and unchecked count badge
- Checked items collapse to a "Checked (N)" disclosure group at the bottom
- Top-right action: "Finish Shopping" → triggers completion flow (confirm dialog → saves PurchaseRecord → confetti)

#### Items Catalogue Screen
- SearchBar at top (always visible, `surfaceVariant` fill)
- Horizontal category filter chips below search bar (scrollable)
- Alphabetically sorted `ListView` of all items, grouped by first letter (sticky section headers)
- FAB: "New Item" → bottom sheet with name, category picker, unit selector

#### History Screen
- Timeline of past shopping sessions, most recent first
- Each entry: date chip + list name + total items count + expandable item breakdown
- Expandable row shows each item with quantity bought

#### Profile / Settings Screen
- User avatar + name + email
- Premium banner (if free): gradient card with upgrade CTA
- Household section (premium): member list with avatars, invite button
- Settings: theme toggle (light/dark/system), notification preferences, account actions

---

### Iconography

Use **Material Symbols** (outlined weight by default, filled on active state). Icon size: 24dp standard, 20dp in dense rows, 32dp in empty states.

Key icon mappings:
- Check: `check_circle` (filled, `primary`) / `radio_button_unchecked` (outline, `outline`)
- Category: `label`
- Add item to list: `playlist_add`
- Quantity: `exposure_plus_1`
- History: `history`
- Premium: `workspace_premium`
- Sync: `sync` (animated rotation when syncing)
- Household/share: `group`
- Delete: `delete_outline` (always in `error` color)

---

### Accessibility

- All interactive elements: minimum touch target **48×48dp**
- Color is never the sole differentiator (always paired with icon or text)
- `Semantics` wrappers on custom widgets: checked state, quantity, and category announced for screen readers
- Contrast ratio: ≥ 4.5:1 for body text, ≥ 3:1 for large text and UI components
- `reduceMotion` check: if `MediaQuery.of(context).disableAnimations`, replace all custom animations with instant transitions
