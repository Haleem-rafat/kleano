# Kleano apps redesign: design document

Date: 2026-10-30 · Apps: **User** (`Kleano-Flutter-dev`, package `thewasher`) and **Biker** (`Kleano-Biker-Flutter-dev`, package `thewhsherbiker`).

## 1. Intent and why

The owner finds both apps look bad and inconsistent: every screen is styled differently, nothing feels like a 2026 app, and the
earlier "Liquid Glass" work only touched a few shared pieces (tab bar, app bars, buttons, home map). The **Biker app is the worst**.
The apps also **feel laggy**. The owner wants a senior mobile engineer + product designer pass: one new design system for both apps,
every screen rebuilt on it, real Apple Liquid Glass on iPhone, a matching modern Android look, better UX, better performance, the
API log viewer back for debugging, and written documentation of the new UI.

Success looks like: opening either app on an iPhone (incl. iPhone Duo) or a recent Android phone and seeing one coherent,
native-feeling product, from the first auth screen to the last settings page, that scrolls and navigates smoothly.

## 2. Goals

1. **One design system, shared by both apps** (tokens + components), approved by the owner (see §5).
2. **Every screen** of both apps rebuilt on it (inventory in §7), **starting with the auth flows**.
3. **iPhone: real Apple Liquid Glass** for the controls layer (native `UIGlassEffect`, `UIButton` glass configurations, `UITabBar`),
   following Apple's HIG: glass only on controls/navigation, content stays opaque, brand colour on tints not bars.
4. **Android: Material 3 Expressive** with the same colours, type sizes, shapes and spacing (not an imitation of iOS glass).
5. **Biker home redesigned** as the approved "map + glass sheet" mix (§6.2) with a new bottom bar: Today / Orders / Earnings / Profile.
6. **Performance:** measurably smoother (see §8).
7. **API log viewer (Chucker) back** in both apps (see §9).
8. **UI documentation** delivered with the work (see §10).
9. Keep everything already fixed working: iPhone Duo fold/side-bar handling, sidebar on regular width, rotation, RTL Arabic,
   token refresh, guest mode, all the bug fixes in `UPGRADE_REPORT.md`.

## 3. Non-goals

- No backend/API contract changes. The apps keep using the current endpoints (BE issues stay in `UPGRADE_REPORT.md`).
- No change to business logic, BLoC/Cubit architecture, repositories, or navigation semantics beyond what a screen's new layout needs.
- No migration to Flutter's new `material_ui`/`cupertino_ui` packages in this project (separate follow-up).
- No new product features beyond what the approved screens show (e.g. Earnings uses the existing `orders/biker/total-commission` data only).

## 4. Anti-goals (would be a failure even if it "works")

- Screens that still mix old and new styles, or one-off colours/sizes outside the tokens.
- Fake glass on iPhone where native glass is available, or iOS-looking glass forced onto Android.
- Purple bars across the top of screens (Apple HIG: no tinted bars; purple is for actions/highlights).
- Anything cut off, overlapping, or under the iPhone Duo side status bar / fold; broken Arabic (RTL) layouts.
- Regressions in flows: login/OTP, booking + payment, order status steps for bikers, notifications.
- Making the apps slower (e.g. too many native platform views in long lists).

## 5. Design system (approved by the owner)

Shared tokens (one Dart source of truth per app, identical in both):

- **Colour:** brand/tint `#543063`, brand light `#8E5BA6`, background `#F2F2F7`, surface `#FFFFFF`, text `#1C1C1E`,
  secondary text `#6E6E73`, success `#34C759`, warning `#FF9500`, error `#FF3B30`. Purple only for actions and highlights.
  **Dark mode** with matching dark values (builder defines the dark palette in the same structure).
- **Type:** platform fonts: SF Pro / SF Arabic on iOS, Roboto / Noto Arabic on Android. Scale: Large title 34, Title 22,
  Headline 17 semibold, Body 17, Subhead 15, Footnote 13 (plus Caption 12 if needed). Respects Dynamic Type / font scale within
  the existing clamp (0.85–1.35). *(The old bundled Roboto/Cairo fonts are replaced by platform fonts: owner approved the type
  sample shown.)*
- **Shape:** continuous (superellipse) corners; capsule buttons; cards ~20–22pt radius; sheets 34pt top radius.
- **Spacing:** 4/8 grid; 44pt minimum tap targets.
- **Components (approved look):** primary button (iOS prominent glass, Android filled), secondary button (iOS glass, Android tonal),
  filled input field with clear focus state, card, status chip (success/warning/error/brand), segmented control, toggle,
  list rows, bottom sheet, dialog, snackbar, glass top bar, tab bar, sidebar, empty/loading/error states.
- Motion: short, physics-based (≈200–400ms), respects Reduce Motion.

## 6. Approved screens

### 6.1 Auth (first stage)
Biker login as approved: purple brand header with logo, sheet below with large title "Welcome back", subtitle, Username, Password
(show/hide), "Remember me" toggle, **primary "Log in" pinned at the bottom above the keyboard** (never cut off), "Forgot password?"
text button. Same pattern for: Biker phone number / OTP / update password; User onboarding, choose register, login, sign up, OTP,
edit-phone OTP. OTP fields keep SMS one-time-code autofill.

### 6.2 Biker home ("mix" of map-first + dashboard)
- Full-screen map with the biker's position.
- Floating glass top bar: avatar (→ profile), "Online / Offline" label + subtitle, online switch, notifications button with badge.
- Glass bottom sheet with three states: **waiting** (today's washes, earned SAR, rating), **new request** (countdown chip,
  service, car, colour, plate, area, time, distance/ETA, "Details" + "Accept request"), **pulled up** (stats, Active/Completed
  segmented control, order cards each showing status chip and its next step as one primary button: On the way → Arrived →
  Start washing (before photo) → Complete (after photo), plus "Navigate").
- Bottom bar: **Today** (this screen) / **Orders** / **Earnings** / **Profile**.
- *Builder's call:* the request countdown chip is shown only if the backend provides an accept deadline; otherwise it is
  omitted (no invented timers). Stats use the data the current analytics section already loads.
- Offline state: same map, sheet explains how to go online with a primary "Go online" button (fixes the untranslated
  `goOnlineNow` label).

### 6.3 All other screens
Rebuilt on the system with the patterns above (large titles, grouped lists, cards, sheets). Screen-level layouts not yet
mocked are left to the builder within the system (§12).
*Builder's call:* the **User app home and booking flow** are the customer's most important screens, so they get a mockup for the
owner's approval (same browser review as the Biker home) **before** stage 5 is built.

## 7. Screen inventory (scope)

**Biker:** splash, onboarding, login, phone number, OTP, update password, home (incl. empty state), notifications, order details,
order change-status (map + steps), profile, account, settings, biker schedule, update biker data; new Orders and Earnings tabs.

**User:** splash, address check, onboarding, choose register, login, sign up, OTP; home (map), guest home, explore, saved places,
search map; booking (main, unified/rest booking, services, add-ons, vehicles, select time, set location, add address, saved
locations, review, order details, payment type(s), payment); my bookings (tabs: active, scheduled, history; wash details);
tracking order (map, status sheet, biker info, contact); my vehicles (list, empty, edit); plans & subscription; points;
notifications (+ guest); profile (user, guest view, account, personal info, edit phone + OTP, promo codes ×3, settings, points
explanation, wallet top-up); about us, contact us, terms.

## 8. Performance

The owner did not single out a screen, so the builder measures before fixing: profile both apps in **profile mode** on the
iPhone 18 Pro simulator and an Android device/emulator, on the heaviest flows (cold start, home map, booking, my bookings
lists, biker home, order status). Fix the measured top offenders; known suspects from the code: whole-screen `setState`/`BlocBuilder`
rebuilds, unbounded image decoding (`cached_network_image` without size hints), shimmer animations left running, maps rebuilding,
startup work done before the first frame, `BackdropFilter`/platform-view overuse in scrolling lists. **Rule:** native glass platform
views only on chrome (bars, floating buttons, sheets), never per list item. Report before/after numbers (frame build/raster times,
startup time).

## 9. API log viewer (Chucker)

Restore Chucker in **both** apps so the owner can inspect requests/responses, **including in the production (store) builds**
(owner decision, 2026-10-30).

- **Dev flavor and debug builds:** always recording; open from Chucker's notification or the hidden entry below.
- **Production (pro) release builds:** **off by default and recording nothing** until enabled by a hidden gesture
  (long-press the app version label in Settings for ~5 s). It then **switches itself off after 24 hours** (enabled-at timestamp
  in local storage) and the gesture also opens the log viewer.
- **Always masked** (all builds): `Authorization` headers, access/refresh tokens in bodies, card number / CVC / expiry fields,
  OTP codes. *(Builder's calls made here: the gesture, the 24 h expiry and the masking list; owner can override.)*
- Risk accepted by the owner: while enabled, request/response data sits on the device (see `UPGRADE_REPORT.md` B-15).

## 10. UI documentation (deliverable)

A design-system document covering: tokens (colours incl. dark mode, type, spacing, radii, motion), every shared component with
when-to-use rules and iOS/Android rendering, screen patterns (auth, map + sheet, lists, details, forms, empty/loading/error),
iPhone Duo / regular-width rules, accessibility rules, and before/after screenshots of each redesigned screen. Delivered as a
Markdown file in the repo **and** as a shareable page.

## 11. Constraints

- Flutter 3.47.8 / Dart 3.13, existing package set (see `UPGRADE_REPORT.md`); iOS 15+ (glass on iOS 26+, fallback below);
  Android minSdk 24 / target 36.
- Native iOS glass lives in `ios/Runner/KleanoNative.swift` (both apps): `kleano/liquid_glass`, `kleano/glass_button`,
  `kleano/tab_bar`, `kleano/fold`. Shared Dart design code currently in `lib/core/design/` (identical file in both apps).
- Both languages (English/Arabic, RTL), all orientations, iPhone Duo outer/inner, Android foldables.
- Existing tests must keep passing; add tests for new shared components and key layouts.
- Work lands in stages, each producing installable builds the owner can try: (1) design system + docs skeleton,
  (2) auth flows both apps, (3) Biker home + Orders/Earnings, (4) remaining Biker screens, (5) User main flows (home,
  booking, payment, tracking), (6) remaining User screens, (7) performance pass + Chucker + final docs.

## 12. Left to the builder

- Exact layouts of screens not mocked (within the system and patterns).
- Dark palette values, motion curves, empty/error illustrations (use existing assets where suitable).
- How to share the design-system code between the two apps (copy-in-sync vs local package).
- Android component specifics within Material 3 Expressive.
