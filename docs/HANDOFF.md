# Kleano redesign — handoff prompt

Paste everything below the line into a new Claude Code session opened at the repo root
(`kleano/`; on the current machine `/home/typezero/Work/insightx/kleano`).

---

You are continuing the Kleano app redesign. Read these first, in order:
`docs/design-system.md`, `docs/backend-review.md`. The redesign spec
(`docs/superpowers/specs/2026-10-30-kleano-redesign-design.md`), `UPGRADE_REPORT.md`,
`reports/`, `docs/screens/` and `docs/kleano-client-guide.html` were on the old machine and are
not in this repo; references to them below are history. The published design system (tokens, components, iOS/Android rules,
layouts) is at https://claude.ai/artifact/CW6q57miq9LELeaHnCxeCk.

## Projects

One git repo (root `kleano/`); each folder used to be its own repo.

- `customer-app/` — customer app (package `thewasher`), source of truth for the shared
  design code in `lib/core/design/`.
- `biker-app/` — biker app (package `thewhsherbiker`).
- After any change under `customer-app/lib/core/design/` run
  `customer-app/tool/sync_design.sh` then `customer-app/tool/sync_design.sh --check`.
  `ios/Runner/KleanoNative.swift` is identical in both apps: copy it across by hand.
- `dashboard/` — React admin dashboard (Vite, Tailwind, shadcn); `npm run dev`, port 4000.
- `landing/` — static marketing page (port 4100 when served locally).
- `backend/` — NestJS 9 + MongoDB API that the apps and dashboard call; plain folder in this
  repo like `dashboard/` (no history before 2026-11-02). The apps use
  `https://kleano-backend.onrender.com/api/`. `backend/.github/workflows/push.yml` is the
  **production** deploy (push to `prod` builds a GHCR image and redeploys the VPS): never
  trigger it. GitHub only runs workflows from the repo root's `.github/`, so it does not run
  from this repo; don't move or copy it there, and don't create a `prod` branch. Run: `npm install`, `npm run start:dev` (port 3000,
  needs `backend/.env`). Checks: `npx tsc -p tsconfig.build.json --noEmit`, `npm run lint`,
  `npm test`. `backend/.env` holds live secrets: never commit it. Review with open security
  issues: `docs/backend-review.md`.
- The old `*-prod` production copies are not in this repo.
- Flutter 3.47.8. Build for the simulator:
  `flutter build ios --simulator --debug --flavor dev -t lib/main_dev.dart`.
  Booted simulator: iPhone 18 Pro. Customer dev bundle id: `co.spiritude.kleanoDev`.
  (Simulator and `~/Library/...` paths below are from the old macOS machine.)

## Owner's goals

- iOS: real Apple Liquid Glass like Apple's own apps — every floating control
  (tab bar, top bars, buttons, back buttons, search, sheets, dialogs, menus) is native
  `UIGlassEffect` / glass `UIButton`; content (lists, cards, text) stays opaque.
- Android: full Material 3 (Expressive), same colours/type/spacing, no fake glass.
- Same brand and layouts in both apps. Egypt is the main market (+20 default).
- The owner gave free rein to improve UX, not just visuals.

## Done (committed)

1. Design system code: tokens, theme, KButton (primary/secondary/text/destructive),
   KTextField, KCard, KStatusChip, KSegmented, KListRow, states, KAuthScaffold,
   GlassTabBar/AppBar/Sidebar, and new KGlassPanel, showKSheet/KSheet, KDialog.
2. Auth screens on the system: Biker (login, phone, OTP, update password) and customer
   (onboarding, choose register, login, sign up, OTP, edit phone + OTP).
3. Egypt default: `AppConstants.defaultDialCode = '+20'`; login/sign-up/edit-phone use
   `buildInternationalPhone` + `PhoneDigitsFormatter` (`lib/utilties/phone_number.dart`).
   Biker WhatsApp links use `lib/utilties/whatsapp_number.dart` (no forced 966).
4. Fixed an iOS launch crash: a content-hugging KButton gave the native glass button
   infinite width. KButton now measures its label; NativeGlassButton refuses unbounded
   constraints. Regression test in `test/design/k_button_test.dart`.
5. Native glass buttons now colour SF Symbols (white back chevron).
6. GuestAlert and DeleteCarAlert use KDialog. Glass buttons over photos use white labels.

Tests: customer 101, biker 38, all passing; 0 analyzer errors in both.

## Next, in order

0. **Tab bar: not an app bug (checked 2026-10-31).** Tabs switch on 50 ms, 100 ms and
   400 ms taps. Only a zero-length automated tap is lost, so when driving the simulator
   pass `duration: 0.1` on tab taps. `GlassTokens.nativeTabBar = false` is no longer
   needed for screenshots. Not yet tried on a real iPhone.
1. Check on the simulator (log out first; the dev install is signed in as the owner):
   - The white back chevron on the auth header. The first fix
     (`imageColorTransformer`) did NOT work; the second (`button.tintColor = color`
     for non-prominent glass in `KleanoNative.swift`) is committed but unseen.
   - KDialog (guest alert), white "Skip"/"Login" labels over photos, the
     "Resend code in mm:ss" label.
   - Retake `docs/screens/user/onboarding-iphone18pro.png`: it currently holds a
     login screenshot by mistake.
2. Move the remaining ~21 dialogs in `lib/shared/components/alert_helper/` and the
   bottom sheets (`booking/bottom_sheet/wait_for_biker.dart`,
   `profile/widgets/wallet_topup_bottom_sheet.dart`, the `showModalBottomSheet` calls in
   `booking/`, `my_vehicles/`, `Home/widget/services_widget.dart`) onto KDialog /
   showKSheet. Do the same in the Biker app.
3. Mockups for owner approval are in the design-system artifact under
   Components → Screens: `BikerHome` and `CustomerHome` (iOS glass + Android M3).
   Build them once the owner approves or comments.
   Stage 3 of the spec: Biker home (map + glass sheet, Today/Orders/Earnings/Profile).
4. Stage 5: customer home and booking flow (mock first for owner approval). The current
   home is still the old style and responds 1–3 s late to taps: profile it in
   profile mode.
5. Remaining screens, then dark mode on (`themeMode` is still light), performance pass,
   Chucker (spec §9), and screenshots in `docs/design-system.md` §7.

## Owner's queue (2026-10-30, in this order)

0. **Done (3dfceac):** a failed saved-locations request looked like "no addresses" and
   opened the first-address map. A failed check now shows a retry plus Add Address. The
   original failure was not reproduced (no logs from it); this launch path was forced with
   an unreachable server and works. Greeting is seen. Still open: a "no addresses" account
   has not been run on the simulator (covered by a bloc test only).
   Home research (owner asked for best practices): keep glass only on navigation/controls;
   one or two hero moments (greeting + service choice); next add a "Book again" card (last
   car + service + address) and an "Active wash" card linking to tracking at the top.
1. **Location add / delete UI: done on iOS, English and Arabic, seen on the simulator.**
   `set_booking_location_screen.dart`, `saved_locations_screen.dart`, `Home/screens/home_screen.dart`
   (the map add screen), `search_map_screen.dart`. New: `KSearchField`, `SavedLocationRow`.
   Not exercised end to end against the live backend (viewed only): actually saving,
   deleting or changing the default. Widget tests cover the delete and default calls.
   There is **no edit**: the backend client has no update-address call, so edit means
   delete and add again. Dead code left alone, no callers: `add_new_address_screen.dart`,
   `add_car_location.dart`, `Home/screens/saved_screen.dart` + `saved_places_tab.dart`,
   `recent_places_tab.dart`, `Home/widget/search_model.dart`. Safe to delete.
   One tap on the map screen's label control took over 1.5 s in a debug build. iOS profile
   mode needs a real device, so measure it there.
2. **Run on Android: started (2026-10-31).** An emulator already exists, no download needed:
   `~/Library/Android/sdk/emulator/emulator -avd Medium_Phone_API_37.0 -gpu host -cores 4 -memory 4096`.
   Without `-gpu host` it falls back to SwiftShader and Android itself stops responding
   ("System UI isn't responding"). Then `flutter run -d emulator-5554 --flavor dev -t lib/main_dev.dart`.
   The emulator is signed in by the owner. Location screens checked on both platforms:
   `docs/screens/location-ios-vs-android.png` (sources in `docs/screens/ios/` and `android/`).
   Not checked on Android: the on-screen keyboard layout (this emulator uses a hardware
   keyboard; forcing it means changing a system input setting). Not run on either platform:
   saving, deleting or changing the default on the live backend.
   Still to do on Android, none of it in the location screens:
   - Tab bar is a blurred floating capsule; the owner's rule is Material 3 `NavigationBar`, no
     fake glass. The Flutter blur in `LiquidGlass` needs the same decision. `docs/design-system.md`
     §4 still describes both: fix it too.
   - The disabled Next `KButton` is translucent, so "Add extras" shows through. Seen only as a
     guest; signed in, Next is solid.
   Small differences to decide: map control and back icons are brand purple on Android but black
   on iOS (the iOS glass button ignores `color` there), and the address line differs because each
   platform's geocoder words `street` differently, and that text is what gets saved.
   **Hot restart warning:** a temporary code edit tested with hot restart stays in the installed
   build until the next full `flutter run`. Rebuild before trusting a relaunch.
3. **Iterate again on Home, Plans, Bookings, Profile** (Home mostly done and seen on the simulator: 9e1479f Next button with total, 0780fd1 glass top bar via new `KChipButton`, plus service cards with brand ring; left: banner carousel styling, add-ons section below, Android check. Earlier note: commit 9e1479f
   turned the gradient Next/Confirm card `booking/widgets/total_pay_card.dart` into a
   KButton showing the total; NOT yet seen on the simulator — check the tap works once
   and the guest state still shows. Home is `booking/screens/booking_main_screen.dart`.) using the real-screen mockups
   in the artifact (Before → After iOS → After Android) and the rules in `CLAUDE.md`.

`cupertino_icons` is now bundled in both apps (commit "bundle cupertino_icons"), so
`CupertinoIcons.*` render; the home screen's restart icon should be checked.

## Vehicle add / edit — DONE (2026-10-30, commits 36ad1b3, 1eaf400), seen on simulator

New shared component `KPickerField` (core/design/components/k_picker_field.dart, synced
to Biker): a field that opens a searchable sheet — **use it to replace every dropdown in
both apps** (owner: dropdowns are "so ugly"). Find the rest with
`grep -rn "DropdownSearchShared\|DropdownButton" lib` in both apps.
Owner rules are now in `CLAUDE.md` (repo root) (everything must match the design system).
The app does not bundle the `cupertino_icons` font: `CupertinoIcons.*` render as "?"
(seen in the picker; also used in `Home/screens/home_screen.dart`). Add `cupertino_icons`
to both pubspecs or use Material icons.
Left on this screen (brand placeholder fixed in a8caa3d):
car card gradient overlay in `shared/widget/vehicle_shared.dart`;
edit mode has no "Delete vehicle" action yet (delete is swipe on the list).

## (was) TOP PRIORITY: vehicle add / edit / delete (owner: "UI so bad, not app principles")

File: `customer-app/lib/modules/my_vehicles/screens/edit_vehicles_screen.dart`
(~1,150 lines; used for create and edit) + `shared/widget/vehicle_shared.dart` (car card)
+ `shared/components/alert_helper/delete_car_alert.dart` (already KDialog).
Seen on the simulator ("Add New Vehicles"):
- Old styles everywhere: `AppStyles`/`ColorManager`, dashed "Upload car photo" box,
  hint-text dropdowns, a grey disabled-looking plate field, a colour row of car icons
  that runs off the screen, gradient purple "Add Vehicle" button.
Rebuild on the system, keeping VehiclesBloc/CarsBloc calls exactly:
- `GlassAppBar` + glass back button; large title "Add vehicle" / "Edit vehicle".
- Photo: a `KCard` with the photo (or the car-type SVG) and a "Choose photo" text
  button; iOS uses the system photo picker sheet.
- Brand and model: tappable `KTextField`-style rows that open a searchable
  `showKSheet` list (not raw dropdowns). Plate: normal `KTextField` with
  `textCapitalization.characters`.
- Colour: a wrapping grid of colour swatches (circle + name), selected = brand ring;
  never a horizontal overflow.
- One primary pinned above the keyboard ("Save vehicle"), loading state while saving;
  in edit mode a destructive "Delete vehicle" text button that opens `DeleteCarAlert`.
- Use the Dart and Flutter + Very Good Flutter plugins (suggested to the owner) for
  widget tests and layout checks; add a widget test for create and edit.

## Owner feedback on the mockups (2026-10-30) — read before designing anything

The flow mockups in the artifact look like generic "AI UI", not like Kleano. Redo them
from the real app before building more screens:

1. Investigate every current screen first: run both apps, screenshot each screen
   (customer + biker, English + Arabic) into `docs/screens/before/`, and list what each
   screen shows and does.
2. Keep the app's own identity: its SVG icons in `assets/svg/` (tab icons, car types,
   coins, payment, empty states), its car/service photos and banners, its wording
   (`assets/i18n/*.json`), its purple brand, its screen structure. Don't swap in
   generic shapes or placeholder icons.
3. Restyle that, don't reinvent it: on iOS the controls become real Liquid Glass (native
   `UITabBar` tabs with the app's own icons, glass buttons, glass sheets/top bars,
   SF Symbols only where the app has no icon); on Android the same screens in Material 3
   (`NavigationBar` with the same icons, filled/tonal buttons, M3 sheets).
   Progress: **CustomerHome is redone this way** (Before screenshot
   `docs/screens/before/customer-home.png` → After iOS → After Android, real icons
   inlined from `assets/svg/`, banner/service photos cropped from the screenshot).
   Also redone from real screenshots (`docs/screens/before/`): BookingsList,
   VehiclesPlans, ProfileFlow (shows the built Profile screen running — row 1 is now
   verified with real data). Still generic: BookingFlow, TrackingFlow, BikerHome,
   BikerFlows. To capture tab screens in the simulator, set
   `GlassTokens.nativeTabBar = false` locally (simulator taps don't reach the native tab
   bar), capture with `xcrun simctl io booted screenshot`, then revert it. Generators:
   the scripts that wrote these cards were in the session scratchpad; the pattern is
   real icons inlined from `assets/svg/` (fill → currentColor) + photos cropped from the
   uploaded screenshot via CSS background-position.
4. Update the artifact's mockup cards from those real screens (before → after per
   screen), get the owner's OK, then implement row by row below.

## Implementation plan: mockups → screens

The owner asked to implement every mockup in the design-system artifact (they are
for a client presentation). Mockup cards live under Components → Screens / Customer
flows / Biker flows. Work one row at a time: rebuild the widget tree on the design
system, keep every BLoC/cubit call and navigation target, add a widget test, run
analyze + tests in both apps, commit, then tick the row here.

| # | Mockup | Files (customer = `customer-app/lib/modules/`, biker = `biker-app/lib/modules/`) | Status |
|---|---|---|---|
| 1 | ProfileFlow · Profile | customer `profile/screens/user_profile_screen.dart` (done: grouped KListRows, logout confirmed in KDialog, KLoading/KErrorState); `profile_guest_view/` still todo; `widgets/list_of_screens_in_profile.dart`, `header_profile.dart`, `my_wallet.dart`, `my_points.dart` now unused, delete after checking | done, seen running with real data |
| 2 | ProfileFlow · Wallet, Notifications | customer `profile/widgets/wallet_topup_bottom_sheet.dart` (→ showKSheet), `notifications/screens/notifications_screen.dart`, `guest_notification_screen.dart` | todo |
| 3 | BookingsList | customer `my_booking/screens/my_booking_tabs.dart`, `my_booking_active.dart`, `my_booking_scheduled.dart`, `my_booking_history.dart`, `wash_details.dart` | todo |
| 4 | VehiclesPlans | customer `my_vehicles/screens/vehicles_list_screen.dart` (done, seen on simulator; `VehiclesCard` gradient overlay from the mockup still todo in `shared/widget/vehicle_shared.dart`), `plans_and_subscription/screens/plans_subscription_screen.dart` (todo) | in progress |
| 5 | CustomerHome | customer `Home/screens/home_screen.dart`, `guest_home.dart`, `layout/main_navigation_screen.dart` | todo |
| 6 | BookingFlow | customer `booking/screens/unified_booking_screen.dart`, `rest_unified_booking_screen.dart`, `add_addons.dart`, `vehicles_screen.dart`, `select_time.dart`, `booking_review.dart`, `payment_type*.dart`, `order_detalis_screen.dart` (careful: payment) | todo |
| 7 | TrackingFlow | customer `tracking_order/screens/*` | todo |
| 8 | BikerHome | biker `Home/screens/home_screen.dart`, `empty_screen.dart` | todo |
| 9 | BikerFlows · Orders, Order steps | biker `order/screens/order_details_screen.dart`, `order_change_status_screen.dart` (new Orders tab) | todo |
| 10 | BikerFlows · Earnings | biker: new Earnings tab from `orders/biker/total-commission` data only | todo |
| 11 | BikerFlows · Profile | biker `profile/screens/*`, `notification/screens/notification_screen.dart` | todo |
| 12 | Remaining | about/contact/terms, promo codes, points, the ~21 alert_helper dialogs (→ KDialog); saved places and search map done | in progress |

Mockups show prices in SAR (what the backend returns today); ask the owner whether the
client wants EGP before shipping.

## Status 2026-10-31 (latest)

Owner's direction: glass on navigation only; content, sheets and dialogs solid. Android keeps the Flutter glass controls (owner asked for it back) with Material 3 around them. Focus on performance. Client guide: `docs/kleano-client-guide.html`; layout research: `reports/Car wash app home layout.md`.
Approved design: Design System https://claude.ai/artifact/WmVGCPkT3vAHz77umXbaRf, Screens and Flows https://claude.ai/artifact/FvxUxgEie9Lt2vvSpJoQfS. It is applied to both apps (customer e7df548, biker 9301833; not pushed). Tests at last run: customer 149, biker 105; 0 analyzer errors.
Latest fixes: customer 944d3da, 28b48bc; biker eed0909, 1e635f8, ba0df8f. Tests: customer 154, biker 105.
Seen running: biker tabs, schedule, settings, notifications, order steps (iOS), biker Orders (Android, before the segment colour fix); customer Home, Profile, Account, points, promo, about, wash details (iOS). Not seen: the Android splash and segment fixes, the moved map label, the Account avatar and phone fixes; customer tracking map, wallet, dialogs, onboarding, login photo; biker login photo (`photo_onboard_three.png` is a hand holding banknotes: check it suits the login).
Client guide updated: https://claude.ai/artifact/8JyAdVtste4WXgCpizqHWE. Still to do: build the Figma files once the Figma plugin is connected (design system, both apps' screens, flows, prototype).
Owner's queue, in order (2026-10-31): dark mode in both apps (`themeMode` is still light; old screens still hard-code colours); test every page and flow in both apps for the client demo, starting with Account; restyle `dashboard/` with shadcn to match the apps, updating the dashboard's stack if needed; build a landing page. Done in this batch: `KSwipeAction` and wash progress bar (stages now go in order; skipping a stage was possible before), `KRatingStars`, dialogs, customer Profile in the biker style, softer Android glass shadow, fixed Android secondary colours. Not seen on a device yet: customer Profile, new dialogs and rating, Android back-button shadow, the `order_pop_up.dart` new-order popup is not restyled further.
Before comparing Android colours, reinstall: a stale customer install (13:58) caused an "Android colours differ" report.
Latest measurements (customer dev profile build, Android emulator, 2026-10-31): start about 2.2 s, memory about 177 MB, build p90 about 1 ms, Home raster p90 9-17 ms with 5-25% of frames over 16.7 ms, Bookings mostly 0 over. Emulator numbers only: measure on a real phone. Release APK dev 83 MB (customer), 78 MB (biker); iOS release builds compile unsigned. Open: customer iOS went black once while idle (no error, restart cleared it, one-minute background did not reproduce it). Not fixed from the crash audit: map_screen stream never cancelled, biker home_screen.dart:128 push without title, guest_home.dart:104 `placemarks.first.street!`, tracking `biker!` from Bookings for statuses other than the two excluded. `as` casts not audited.
Added 2026-10-31 (later): dark mode foundation (`KThemeMode`, `KThemePicker`, light stays the default; iOS window style set over `kleano/appearance`); seen dark on customer Home, Settings, Vehicles, Bookings, Plans before the last fixes. Older screens with fixed colours not converted: edit vehicle, onboarding, guest home, order review parts, and the shared old buttons and fields. Dashboard: git baseline created in `dashboard/`; login, sidebar and theme restyled; run `npm run dev` (port 4000); inner pages unseen, need the owner's login. Landing page: `landing/` (port 4100). Store links and contact details still missing. Before the repo push: real keys are tracked (see the session's secret scan), so the repo must be private.
Customer Home is the owner's chosen Mix layout (2026-10-31): photo fading into the page, Liquid Glass top controls, wash card with animated stage bar, photo service tiles with See all on the title line, gradient plans card, offers, three promise cards. Other Home versions were removed. Most booked comes from the customer's own finished washes. Live status on Home updates on reload only.
Device rule: the owner may be using the emulator or simulator. Confirm first and screenshot before every tap. Blind `adb` taps can land on Confirm Order, which places a real order on the live backend.
Suspected, unfixed: biker start/complete wash event may never send (`context.mounted` on a popped sheet in `event_stepper.dart`, `button_complete_wash.dart`), high priority; one service tap sends AddServiceCart twice (`main_services.dart` toggle plus `services_list.dart` callback; total stayed correct); Apple Pay/wallet total may ignore applied points; dev Apple merchant ID hard-coded; card payment leaves Confirm disabled after closing the sheet; order listener fires once per payment row; `country: "saudi arabia"` hard-coded; WhatsApp 966 prefix in `biker_details.dart`; biker completed pagination uses `activePageNumber`. Full lists were in the session reports.

## Open decisions for the owner

- Edit phone: Save and Verify were never wired to the API (`PATCH users/phone-number`,
  no OTP check). Left as TODOs; wiring it changes behaviour.
- Dark mode: white text on dark brand `#b88cd0` fails contrast; recommended `#1c1c1e`.
- The dev app works against the live backend `kleano-backend.onrender.com` (both
  flavors use it, `customer-app/lib/api/app_config.dart`). A separate staging backend is
  recommended (UPGRADE_REPORT BE-10), now possible since `backend/` is in the repo.
- Backend security fixes (`docs/backend-review.md`): the Moyasar webhook is unverified (free
  wallet credit, orders marked paid), biker accounts can be taken over from a phone number,
  Qoyod routes are public, any user can cancel or read anyone's order or wallet. The fixes
  are small but need a deploy to the live server: ask before deploying.

## Backend (added 2026-11-02)

`backend/` was added to the repo on 2026-11-02 and reviewed the same day (read only, no
changes): `docs/backend-review.md`. Open, in order: the eight "Fix first" items there (unverified
Moyasar webhook, biker reset from `check-phone`, public Qoyod routes, order and wallet owner
checks, Tamara checkout proxy, wallet double spend, writes outside the transaction), then OTP
throttling, the `000000` test numbers and `.env` baked into the Docker image. Several app-side
"suspected" items above may be backend bugs too: check the backend before patching the app.

## Rules for the agent

- Don't type OTP codes or passwords into the app: it talks to the live backend. Open the
  screen and ask the owner to type them in the simulator panel.
- Commit in the root repo after each verified step; never push.
- Don't deploy the backend or call its admin, payment or webhook routes on the live server.
- One primary button per screen; brand purple only for actions; no purple bars.

## Glass and loading (2026-10-31)

- Apple's "Adopting Liquid Glass" page was read through its JSON. On a photo, chips and the bell
  are Apple's real clear glass button; the WhatsApp button is glass in both apps; icon-only glass
  buttons pass a VoiceOver label.
- Not adopted: `GlassEffectContainer`/morphing and tab-bar minimise on scroll, since each glass
  piece is a separate platform view and the tab bar is a bare `UITabBar`. Sheets stay solid
  (owner's rule), although Apple makes them glass.
- `KSkeleton.list/.grid/.details` replaced the spinner on lists and screens.
- Don't test the emulator during a build: the Mac overloads and Android shows "isn't responding".

## Live wash status (2026-10-31)

- Customer app: `WashLiveStatus` feeds iOS Live Activity / Dynamic Island (`ios/WashLiveActivity`,
  `WashLiveActivityBridge.swift`) and an Android ongoing progress notification.
- It updates from the active order on Home and socket events, so **only while the app is running**.
  Live updates with the app closed need the backend: ActivityKit pushes through APNs on iOS, and
  FCM data messages on Android. Not built.
- Personal Team iPhone builds temporarily swap team and bundle IDs and drop the entitlements file,
  then restore `project.pbxproj`. Never commit that swap.
