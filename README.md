# Kleano

Kleano is a mobile car wash platform. A customer books a wash in the app, a biker drives to the car
and washes it, and the customer follows the wash live. The admin team runs everything from a web
dashboard. Egypt is the main market (`+20` is the default dial code), and every app has English
and Arabic.

This repo holds every part of the platform:

| Folder | What it is | Stack |
| --- | --- | --- |
| [`customer-app/`](customer-app) | App for customers: book washes, manage cars, plans, wallet | Flutter, BLoC |
| [`biker-app/`](biker-app) | App for bikers: receive orders, update wash status, earnings | Flutter, BLoC |
| [`dashboard/`](dashboard) | Admin web dashboard | React, Vite, Tailwind, shadcn/ui |
| [`backend/`](backend) | API used by both apps and the dashboard | NestJS 9, MongoDB, Socket.IO |
| [`landing/`](landing) | Marketing page | Static HTML |
| [`docs/`](docs) | Design system, handoff notes, backend review | Markdown |

Live API: `https://kleano-backend.onrender.com/api/`
Design system page: https://claude.ai/artifact/CW6q57miq9LELeaHnCxeCk

---

## How the parts fit

```
customer-app ─┐
biker-app ────┼──  REST + Socket.IO  ──▶  backend (NestJS)  ──▶  MongoDB
dashboard ────┘                              │
                                             ├─ Firebase (push notifications, file storage)
                                             ├─ Payments: Moyasar, Tabby, Tamara
                                             ├─ Qoyod (invoices / accounting)
                                             ├─ OurSMS (OTP codes)
                                             └─ Email (Nodemailer)
```

- The apps call REST under `/api/` and get live order updates over Socket.IO.
- Push notifications go through Firebase Cloud Messaging.
- The customer app shows the live wash status in an iOS Live Activity / Dynamic Island and in an
  Android ongoing notification.

---

## Customer app — `customer-app/`

Flutter package `thewasher`, version 3.0.0.

**Features** (`lib/modules/`)

| Module | What it does |
| --- | --- |
| `splash`, `on_boarding` | Start-up, intro screens, choose sign up or log in |
| `Auth` | Phone log in and sign up with OTP, edit phone |
| `Home` | Home screen, offers and banners, saved locations, map to add an address |
| `booking` | Book a wash: service, add-ons, car, address, date and time, payment |
| `my_booking` | Current and past washes, wash details and photos |
| `tracking_order` | Live tracking of the biker and the wash stages |
| `my_vehicles` | Add, edit and delete cars (brand, model, plate, colour, photo) |
| `plans_and_subscription` | Wash plans and subscriptions |
| `points` | Loyalty points |
| `profile` | Profile, wallet and top-up, settings, language, log out |
| `notifications` | Notification list; tapping a push opens it |
| `about_us` | About, contact, terms and conditions (formatted from the dashboard) |

**Code layout** (`lib/`)

- `api/` Dio client and `app_config.dart` (base URL)
- `core/design/` the shared design system (see below)
- `models/`, `responses/`, `repository/` data
- `shared/` shared widgets, alerts and helpers
- `localization/` and `assets/i18n/en.json`, `ar.json` translations
- `layout/` main tab navigation
- `main_dev.dart`, `main_pro.dart` entry points for the `dev` and `pro` flavours

## Biker app — `biker-app/`

Flutter package `thewhsherbiker`, version 1.0.5.

| Module | What it does |
| --- | --- |
| `splash`, `on_boarding` | Start-up and intro |
| `Auth` | Log in, phone and OTP, update password |
| `Home` | Today's orders and the map |
| `order` | Order details, change wash status, stage changes, wash photos, report a failed wash |
| `notification` | Notification list, mark as read |
| `profile` | Profile, earnings, log out |

Same code layout as the customer app (`api/`, `core/design/`, `models/`, `shared/`, …).

## Running the Flutter apps

Flutter 3.47.8 (Dart ≥ 3.9). Each app has two flavours: `dev` and `pro`.

```bash
cd customer-app            # or biker-app
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart
```

- iOS simulator build:
  `flutter build ios --simulator --debug --flavor dev -t lib/main_dev.dart`
- Android emulator: start it with `-gpu host` or Android becomes unresponsive, then
  `flutter run -d emulator-5554 --flavor dev -t lib/main_dev.dart`
- Customer dev bundle id: `co.spiritude.kleanoDev`

Both flavours currently talk to the **live** backend, so don't type real OTP codes or
passwords in test runs.

**Checks before a commit**

```bash
flutter analyze        # 0 errors
flutter test
customer-app/tool/sync_design.sh --check
```

---

## Design system — `lib/core/design/`

Both apps share one design system. The customer app is the source; the biker app gets a copy.

- Tokens: `KColors`, `KType`, `KSpace`, `KRadius`, `KMotion` (`tokens.dart`, `kleano_theme.dart`)
- Components: `KButton`, `KTextField`, `KPickerField` (searchable dropdown), `KSearchField`,
  `KCard`, `KListRow`, `KStatusChip`, `KSegmented`, `KDialog`, `showKSheet`, `KChipButton`,
  `KStageBar`, `KRatingStars`, `KSwipeAction`, `KAuthScaffold`, loading / empty / error states
- Navigation: `GlassAppBar`, `GlassBackButton`, `GlassTabBar` (`liquid_glass.dart`)

Rules:

- Build every screen only from these pieces. No old `AppStyles` / `ColorManager`, no
  hard-coded colours, font sizes or radii, no gradient buttons.
- Glass is for navigation only (tab bar, top bar and back buttons, controls over a map).
  Content, cards, sheets and dialogs are solid.
- iOS uses Apple's real Liquid Glass (native code in `ios/Runner/KleanoNative.swift`).
  Android uses Material 3 with a light Flutter glass for the navigation layer.
- After changing anything in `customer-app/lib/core/design/`, run
  `customer-app/tool/sync_design.sh` to copy it to the biker app.
  `KleanoNative.swift` must be copied across by hand.

Full guide: [`docs/design-system.md`](docs/design-system.md).

---

## Dashboard — `dashboard/`

React admin dashboard (Vite, TypeScript, Tailwind, shadcn/ui, Redux Toolkit, SWR,
react-hook-form + zod, FullCalendar, Google Maps / Leaflet, i18next).

Sections (`src/modules/`): dashboard stats, orders, assign orders, booking and booking
calendar, users, bikers and biker schedules, admins, washing services, add-ons, plans,
points, promo codes, segments, banners, icons, notifications, transactions, contact info,
terms and conditions, profile.

```bash
cd dashboard
npm install
npm run dev            # http://localhost:4000
npm run build
npm run lint
```

Environment (`dashboard/.env`): `VITE_API_BASE`, `VITE_GOOGLE_MAPS_API_KEY`.
Other modes: `npm run dev:local` (local backend), `npm run dev:msw` (mock API).
Deployed on Vercel (`vercel.json`).

---

## Backend — `backend/`

NestJS 9 + MongoDB (Mongoose). All routes start with `/api/`. Socket.IO for live updates,
scheduled jobs with `@nestjs/schedule`.

Modules (`src/`): auth, user, bikers, biker-schedule, admin, vehicles, car, locations, area,
city, washing-services, add-ons, plans, subscriptions, orders, booking-availability, payments,
wallet, points, promo-code, segments, banners, services-icons, notifications, contact-info,
terms-conditions, tabby, tamara, qoyod, health.

```bash
cd backend
npm install
npm run start:dev      # http://localhost:3000/api/
```

Checks: `npx tsc -p tsconfig.build.json --noEmit`, `npm run lint`, `npm test`.

**Environment** (`backend/.env`, never commit it). Variables the code reads:

| Group | Variables |
| --- | --- |
| Server | `PORT`, `NODE_ENV`, `DOMAIN_URL`, `API_SECRET_KEY` |
| Database | `DB` |
| Auth | `ACCESS_TOKEN_SECRET`, `REFRESH_TOKEN_SECRET`, `SALT_OF_ROUND` |
| Firebase | `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY`, `FIREBASE_STORAGE_BUCKET` |
| SMS (OTP) | `OURSMS_API_KEY`, `OURSMS_BASE_URL`, `OURSMS_SOURCE` |
| Email | `NODEMAILER_HOST`, `NODEMAILER_EMAIL_FROM`, `NODEMAILER_PASSWORD` |
| Moyasar | `MOYASAR_WEBHOOK_SECRET` |
| Tabby | `TABBY_MERCHANT_CODE`, `TABBY_BASE_URL_DEV/PROD`, `TABBY_PUBLIC_KEY_DEV/PROD`, `TABBY_SECRET_KEY_DEV/PROD` |
| Tamara | `TAMARA_API_KEY_DEV/PROD`, `TAMARA_BASE_URL_DEV/PROD`, `TAMARA_NOTIFICATION_TOKEN_DEV/PROD` |
| Qoyod | `QOYOD_API_KEY`, `QOYOD_BASE_URL` |
| Features | `PROMO_STREAMS_ENABLED` |

**Deploy:** `backend/.github/workflows/push.yml` is the production deploy (a push to a
`prod` branch builds a Docker image and redeploys the server). It does not run from this
repo. Don't move it to the root `.github/` and don't create a `prod` branch without the
owner's OK. Open security notes: [`docs/backend-review.md`](docs/backend-review.md).

---

## Landing page — `landing/`

A single static page (`index.html` + `img/`). Open it in a browser or serve the folder,
for example `npx serve landing -l 4100`.

---

## Docs — `docs/`

- [`HANDOFF.md`](docs/HANDOFF.md) — what's done, what's next, how to pick up the work
- [`design-system.md`](docs/design-system.md) — tokens, components and iOS / Android rules
- [`backend-review.md`](docs/backend-review.md) — backend review and open issues
- [`CLAUDE.md`](CLAUDE.md) — rules for every change in this repo

## Working rules (short)

- Keep BLoC / cubit calls, navigation and validation unchanged when restyling a screen.
- Keep the app's own identity: its icons in `assets/svg/`, its photos, its wording.
- No timers that rebuild screens, no fixed delays before loading, sized images.
- Never commit secrets (`backend/.env`, dashboard `.env`).
