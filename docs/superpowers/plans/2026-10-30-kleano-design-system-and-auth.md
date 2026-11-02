# Kleano Design System + Auth Screens Implementation Plan (stages 1–2)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the new shared design system (tokens, theme, components, auth layout, docs) and rebuild every auth/entry screen of both apps on it.

**Architecture:** Design-system code lives in `lib/core/design/` of the **User app** (source of truth) and is copied byte-identical into the **Biker app** by `tool/sync_design.sh`. Components render Apple-native Liquid Glass on iOS (via the existing `NativeGlassButton` / `LiquidGlass` platform views in `liquid_glass.dart`) and Material 3 Expressive widgets on Android. Screens keep their existing BLoCs, controllers, events and navigation; only the widget trees change.

**Tech Stack:** Flutter 3.47.8 / Dart 3.13, flutter_bloc, flutter_screenutil (via `AdaptiveScreenUtil`), flutter_translate, flutter_svg, pin_code_fields 9.x.

**Spec:** `docs/superpowers/specs/2026-10-30-kleano-redesign-design.md` (§5 design system, §6.1 auth, §10 docs, §11 constraints).

Paths below are relative to `/Users/mac/Documents/prsonal/Kleno-app/`. `U/` = `Kleano-Flutter-dev/` (package `thewasher`), `B/` = `Kleano-Biker-Flutter-dev/` (package `thewhsherbiker`).

## Global Constraints

- Colours (spec §5): brand `#543063`, brand light `#8E5BA6`, background `#F2F2F7`, surface `#FFFFFF`, text `#1C1C1E`, secondary `#6E6E73`, success `#34C759`, warning `#FF9500`, error `#FF3B30`. Purple only for actions/highlights; no purple bars except the auth brand header (approved mock).
- Type scale: largeTitle 34/w800, title 22/w700, headline 17/w600, body 17/w400, subhead 15/w400, footnote 13/w400, caption 12/w400. **No `fontFamily`** in new code (platform fonts: SF/SF Arabic on iOS, Roboto/Noto on Android).
- Radii: button capsule, field 14, card 22, sheet 34, dialog 30. Spacing 4/8 grid: 4, 8, 12, 16, 20, 24, 32. Min tap target 44.
- Motion: fast 200 ms, normal 300 ms, slow 400 ms, curve `Curves.easeOutCubic`; Reduce Motion → `Duration.zero`.
- iOS controls use native glass (`NativeGlassButton`, `LiquidGlass`); Android uses Material 3 widgets. Never a platform view per list item.
- Dark palette is defined now, but `MaterialApp.themeMode` stays `ThemeMode.light` until every screen is migrated (later plan) to avoid half-dark screens.
- Every new user-facing string goes through `translate()` with keys added to **both** `assets/i18n/en.json` and `ar.json` of the app that uses it (Arabic provided in the task).
- RTL, all orientations, iPhone Duo outer (`SystemBarInset`) and regular width must keep working; existing 29 (U) / 27 (B) tests must keep passing.
- Business logic untouched: same BLoC/Cubit classes, events, states, controllers, navigation targets.

## Review Focus

1. **Keyboard open on a small phone (375×667, 300 pt keyboard):** the primary auth button stays fully visible above the keyboard. Test in Task 5.
2. **Arabic / RTL:** auth layout mirrors (logo, back button, field text alignment, show-password icon on the leading-opposite side). Test in Task 5.
3. **iPhone Duo outer display (466×678, right inset 90):** no auth content under the side status bar. Test in Task 5.
4. **Long translated strings / text scale 1.35:** titles wrap, nothing overflows. Test in Task 3 (fields/buttons) and Task 5 (scaffold).
5. **Loading state double-submit:** while a request runs, the primary button shows progress and ignores taps. Test in Task 3.

---

### Task 0: Checkpoint the current upgrade work

**Files:** none created.

- [ ] **Step 1:** In both `U/` and `B/`: `git add -A && git commit -m "chore: upgrade audit, native glass, Duo support (pre-redesign checkpoint)"`. Expected: one commit per repo on top of `Baseline before upgrade audit`.
- [ ] **Step 2:** Run `flutter test` in both. Expected: `All tests passed!` (U 29, B 27).

### Task 1: Design tokens + docs skeleton

**Files:**
- Create: `U/lib/core/design/tokens.dart`
- Create: `docs/design-system.md` (root, owned by U)
- Test: `U/test/design/tokens_test.dart`

**Interfaces:**
- Produces:
  - `class KColors { final Color brand, brandLight, background, surface, text, textSecondary, success, warning, error, separator, fill; static const KColors light; static const KColors dark; static KColors of(BuildContext) }` (`of` reads `Theme.of(context).brightness`).
  - `abstract final class KType { static const TextStyle largeTitle, title, headline, body, subhead, footnote, caption; }` (no colour, no fontFamily; letterSpacing −0.4 on largeTitle).
  - `abstract final class KSpace { static const double xs=4, s=8, m=12, l=16, xl=20, xxl=24, xxxl=32; static const double tapTarget=44; }`
  - `abstract final class KRadius { static const double field=14, card=22, sheet=34, dialog=30; }`
  - `abstract final class KMotion { static const Duration fast, normal, slow; static const Curve curve; static Duration of(BuildContext, Duration d) }` (`of` returns `Duration.zero` when `MediaQuery.disableAnimationsOf`).

- [ ] **Step 1: Write failing tests** in `tokens_test.dart`: `KColors.light.brand == const Color(0xFF543063)`, `.background == Color(0xFFF2F2F7)`, `.textSecondary == Color(0xFF6E6E73)`, success/warning/error values from Global Constraints; `KType.largeTitle.fontSize == 34 && fontWeight == FontWeight.w800 && fontFamily == null`; every KType style has `fontFamily == null`; `KRadius.card == 22`; `KSpace.tapTarget == 44`; `KMotion.of` returns `Duration.zero` under `MediaQuery(data: MediaQueryData(disableAnimations: true))`; `KColors.of` returns `KColors.dark` inside `Theme(data: ThemeData(brightness: Brightness.dark))`.
- [ ] **Step 2:** `cd U && flutter test test/design/tokens_test.dart` → FAIL (file missing).
- [ ] **Step 3:** Implement `tokens.dart`. Dark palette (builder's values, keep them): brand `#B88CD0`, brandLight `#8E5BA6`, background `#000000`, surface `#1C1C1E`, text `#FFFFFF`, textSecondary `#98989F`, success `#30D158`, warning `#FF9F0A`, error `#FF453A`; separator light `#3C3C4349`/dark `#54545899`; fill light `#78788029`/dark `#7878805C`.
- [ ] **Step 4:** Run the test → PASS.
- [ ] **Step 5:** Create `docs/design-system.md` with sections: Principles (HIG layering, purple = actions), Tokens (tables generated from the values above), Components (placeholder headings: Button, Text field, Card, Status chip, Segmented control, List row, States, Auth scaffold), Platform rendering (iOS glass vs Android M3E), iPhone Duo & regular width rules, Accessibility, Screens (filled in later plans).
- [ ] **Step 6: Commit** `feat(design): tokens and design-system doc skeleton`.

### Task 2: Theme + wiring into both apps + sync script

**Files:**
- Create: `U/lib/core/design/kleano_theme.dart`
- Create: `U/tool/sync_design.sh`
- Modify: `U/lib/app.dart` (`_buildAppTheme` → `kleanoTheme`), `B/lib/app.dart` (`getApplicationTheme` → `kleanoTheme`)
- Test: `U/test/design/kleano_theme_test.dart`

**Interfaces:**
- Consumes: Task 1 tokens; `LiquidGlassTheme.apply` (existing, keeps page transitions/sheet constraints).
- Produces: `ThemeData kleanoTheme({required Brightness brightness})`; `tool/sync_design.sh [--check]` copies `U/lib/core/design/` → `B/lib/core/design/` rewriting `package:thewasher/` → `package:thewhsherbiker/`; `--check` exits 1 and prints differing files if not in sync.

- [ ] **Step 1: Failing tests:** light theme: `useMaterial3 == true`, `colorScheme.primary == Color(0xFF543063)`, `scaffoldBackgroundColor == Color(0xFFF2F2F7)`, `textTheme.bodyLarge!.fontFamily` is not `'Roboto'`/`'Cairo'` (platform default), `filledButtonTheme.style!.shape!.resolve({})` is `StadiumBorder`, `inputDecorationTheme.filled == true` and border radius 14, `cardTheme.shape` radius 22 superellipse, `bottomSheetTheme.shape` top radius 34; dark theme: `colorScheme.brightness == Brightness.dark`, `scaffoldBackgroundColor == Colors.black`.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implement `kleanoTheme`: `ColorScheme.fromSeed(seedColor: brand, brightness:)` then `.copyWith(primary: brand, surface: surface, error: error)`; textTheme mapped from KType (displaySmall=largeTitle, titleLarge=title, titleMedium=headline, bodyLarge=body, bodyMedium=subhead, bodySmall=footnote, labelSmall=caption) coloured with `text`/`textSecondary`; Material 3 Expressive component themes (FilledButton/ tonal/ Outlined/ Text capsule, min size 44, NavigationBar, SegmentedButton, Switch, InputDecoration filled with `fill`, no border, focused border 2 px brand radius 14); finish with `LiquidGlassTheme.apply(theme, primary: brand)`.
- [ ] **Step 4:** In both `app.dart`: `theme: kleanoTheme(brightness: Brightness.light)`, `darkTheme: kleanoTheme(brightness: Brightness.dark)`, `themeMode: ThemeMode.light`; the `MaterialApp.builder` keeps `BackdropGroup`, `clampTextScale`, `FoldScope`, `SystemBarInset` but no longer wraps a `Theme`. Old screens keep `AppStyles`/`ColorManager` until migrated.
- [ ] **Step 5:** Write `tool/sync_design.sh` (bash, `set -euo pipefail`, rsync `--delete` of `lib/core/design/` then `sed -i ''` package rename; `--check` mode diffs a temp copy). Run `U/tool/sync_design.sh` then `U/tool/sync_design.sh --check` → exit 0.
- [ ] **Step 6:** Run theme test → PASS; `flutter test` in U and B → all pass; `flutter analyze` in both → 0 errors.
- [ ] **Step 7: Commit** in both repos `feat(design): Kleano theme (light/dark) wired in; sync script`.

### Task 3: Buttons and text fields

**Files:**
- Create: `U/lib/core/design/components/k_button.dart`, `U/lib/core/design/components/k_text_field.dart`
- Modify: `docs/design-system.md` (Button, Text field sections)
- Test: `U/test/design/k_button_test.dart`, `U/test/design/k_text_field_test.dart`

**Interfaces:**
- Consumes: tokens, `NativeGlassButton`/`GlassButtonStyle` from `liquid_glass.dart`.
- Produces:
  - `enum KButtonVariant { primary, secondary, text }`
  - `class KButton extends StatelessWidget { const KButton({required String label, required VoidCallback? onPressed, KButtonVariant variant = KButtonVariant.primary, bool loading = false, bool expand = true, IconData? icon, String? sfSymbol}) }` — iOS: `NativeGlassButton` (primary→`prominent` tinted brand, secondary→`glass`, text→plain `CupertinoButton`) wrapped in `SizedBox(height: 50)`; while `loading` shows a `CupertinoActivityIndicator` in a glass capsule and `onPressed` is ignored. Android: `FilledButton` / `FilledButton.tonal` / `TextButton`, height 52, `CircularProgressIndicator` when loading.
  - `class KTextField extends StatefulWidget { const KTextField({required String label, TextEditingController? controller, String? hint, bool obscure = false, TextInputType? keyboardType, List<String>? autofillHints, String? Function(String?)? validator, TextInputAction? textInputAction, ValueChanged<String>? onSubmitted, Widget? prefix, FocusNode? focusNode}) }` — label above (footnote, textSecondary), filled field (theme), show/hide eye toggle when `obscure`, error text below.

- [ ] **Step 1: Failing tests** (`debugDefaultTargetPlatformOverride` per test, reset in tearDown):
  - `primary on Android renders FilledButton with label` ; `secondary on Android renders FilledButton.tonal` (find `FilledButton` whose style differs, or by key `ValueKey('k-button-secondary')`).
  - `primary on iOS renders NativeGlassButton(style: prominent)` (mock `SystemChannels.platform_views` with `tester.binding.defaultBinaryMessenger.setMockMethodCallHandler` returning null).
  - `loading ignores taps`: tap while `loading: true` → callback count 0, progress indicator found.
  - `at text scale 1.35 and width 320 the label does not overflow` (`tester.takeException()` is null).
  - KTextField: `obscure toggles visibility` (tap eye → `EditableText.obscureText` false); `validator error shows below field` inside a `Form` after `validate()`; `label is announced` (`find.bySemanticsLabel`).
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implement both files per Interfaces.
- [ ] **Step 4:** Run tests → PASS. Run `tool/sync_design.sh`.
- [ ] **Step 5:** Fill the Button and Text field sections of `docs/design-system.md` (when to use each variant, iOS vs Android rendering, loading rule).
- [ ] **Step 6: Commit** both repos `feat(design): KButton and KTextField`.

### Task 4: Display components (card, status chip, segmented control, list row, states)

**Files:**
- Create: `U/lib/core/design/components/k_card.dart`, `k_status_chip.dart`, `k_segmented.dart`, `k_list_row.dart`, `k_states.dart`
- Modify: `docs/design-system.md`
- Test: `U/test/design/k_display_test.dart`

**Interfaces:**
- Produces:
  - `KCard({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(16), VoidCallback? onTap})` — surface colour, radius 22 superellipse, soft shadow (light) / none (dark).
  - `enum KStatus { brand, success, warning, error, neutral }`; `KStatusChip({required String label, required KStatus status})` — 12% tinted background, label in status colour (darker shade for contrast: success `#1F8A3D`, warning `#C25E00`, error `#D70015` in light).
  - `KSegmented<T>({required Map<T, String> segments, required T selected, required ValueChanged<T> onChanged})` — iOS: `CupertinoSlidingSegmentedControl`; Android: `SegmentedButton<T>` single-select.
  - `KListRow({required String title, String? subtitle, Widget? leading, Widget? trailing, VoidCallback? onTap, bool showChevron = false})` — min height 44, chevron mirrors in RTL.
  - `KEmptyState({required String title, String? message, IconData icon, String? actionLabel, VoidCallback? onAction})`, `KLoadingState()`, `KErrorState({required String message, required VoidCallback onRetry})`.

- [ ] **Step 1: Failing tests:** chip colours (`KStatus.success` text colour `#1F8A3D` in light); segmented renders `CupertinoSlidingSegmentedControl` on iOS and `SegmentedButton` on Android and calls `onChanged`; list row chevron is `Icons.chevron_right` in LTR and visually mirrored in RTL (`Directionality` rtl → icon `chevron_left` or `matchTextDirection: true`); `KErrorState` retry calls back; all render without overflow at 320 width & text scale 1.35.
- [ ] **Step 2:** Run → FAIL. **Step 3:** Implement. **Step 4:** Run → PASS, sync.
- [ ] **Step 5:** Document each in `docs/design-system.md`.
- [ ] **Step 6: Commit** both repos `feat(design): card, status chip, segmented, list row, states`.

### Task 5: Auth scaffold

**Files:**
- Create: `U/lib/core/design/components/k_auth_scaffold.dart`
- Modify: `docs/design-system.md` (Auth scaffold)
- Test: `U/test/design/k_auth_scaffold_test.dart`

**Interfaces:**
- Consumes: tokens, `KButton`, `GlassBackButton` (existing), `SystemBarInset` (existing).
- Produces: `KAuthScaffold({required String title, String? subtitle, required List<Widget> children, required Widget primaryAction, Widget? secondaryAction, bool showBack = false, VoidCallback? onBack, String logoAsset = 'assets/svg/kleno_logo.svg', String? badge})`
  - Brand header: height `clamp(160, 0.26 * screenHeight, 220)`, radial gradient `#8E5BA6 → #543063 → #2D1838`, white logo SVG + optional `badge` text (e.g. "Biker"), `GlassBackButton(color: white)` top-leading when `showBack`; header shrinks to 96 when the keyboard is open (animated with `KMotion`).
  - Sheet: background colour, top radius 34, overlaps header by 28; scrollable content: `title` (largeTitle), `subtitle` (subhead, textSecondary), 24 gap, `children`.
  - **Pinned actions:** `primaryAction` (+ `secondaryAction` below, 12 gap) in a bottom area padded by `max(viewInsets.bottom, viewPadding.bottom) + 16`, outside the scroll view, so they sit above the keyboard. Light status-bar icons over the header.

- [ ] **Step 1: Failing tests:**
  - `primary action fully visible with keyboard open on a small phone`: view 375×667 dpr 3, `tester.view.viewInsets = FakeViewPadding(bottom: 300*3)`; the rect of the primary button's bottom ≤ 667 − 300.
  - `RTL mirrors back button`: with `TextDirection.rtl`, back button's center x > screen width / 2.
  - `iPhone Duo outer: nothing under the side status bar`: 466×678, padding right 90, wrapped in `SystemBarInset`; scaffold title rect right ≤ 466 − 90.
  - `long title at text scale 1.35 wraps without overflow` (no exception).
- [ ] **Step 2:** Run → FAIL. **Step 3:** Implement (`Scaffold(resizeToAvoidBottomInset: false)` + manual inset handling so header shrink and pinned area are controlled). **Step 4:** Run → PASS, sync.
- [ ] **Step 5:** Document the auth pattern (structure diagram, when to use secondary action, keyboard rule).
- [ ] **Step 6: Commit** both repos `feat(design): auth scaffold with pinned actions`.

### Task 6: Biker auth screens

**Files:**
- Modify: `B/lib/modules/Auth/screens/log_in_screen.dart`, `phone_number.dart`, `otp_screen.dart`, `update_password.dart`, `B/lib/modules/Auth/widget/pin_code.dart`, `B/lib/modules/on_boarding/on_boarding_screen.dart`
- Modify: `B/assets/i18n/en.json`, `ar.json`
- Test: `B/test/auth/biker_auth_screens_test.dart`

**Interfaces:**
- Consumes: `KAuthScaffold`, `KTextField`, `KButton`, `KSegmented` not needed; existing `AuthBloc`/`AuthState` (`BikerLoginLoading`, `BikerLoginSuccess`, `BikerLoginFailed`, …), `PinCodeWidget`, controllers `nameController`/`passWordController`.
- Produces: no new public API.

New strings (key: en / ar): `welcomeBack`: "Welcome back" / "مرحبًا بعودتك"; `bikerLoginSubtitle`: "Log in to start receiving wash requests" / "سجّل الدخول لتبدأ استقبال طلبات الغسيل"; `rememberMe`: "Remember me" / "تذكرني"; `username`: "Username" / "اسم المستخدم"; `badgeBiker`: "Biker" / "الكابتن".

- [ ] **Step 1: Failing tests** (setUp: `SharedPreferences.setMockInitialValues({})`, `sl.reset()` then `sl.registerLazySingleton<AuthBloc>(() => AuthBloc())`; pump inside `LocalizedApp(await LocalizationDelegate.create(fallbackLocale: 'en', supportedLocales: ['en', 'ar']), MaterialApp(...))` created in `setUpAll` with `TestWidgetsFlutterBinding.ensureInitialized()`, so real `assets/i18n` strings are asserted; the empty-field rule: if `_login` has no validation today, add required `validator`s so no request is sent with empty fields):
  - `login shows Welcome back, Username and Password fields, Log in button`.
  - `Log in stays visible with keyboard open on 375×667`.
  - `tapping Log in with empty fields shows validation errors and does not add a login event` (spy via a subclass of `AuthBloc` overriding `add`).
  - `loading state shows progress in the button` (emit `BikerLoginLoading`).
  - OTP: `six-digit code field present and autofill hint oneTimeCode`.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Rebuild `log_in_screen.dart` on `KAuthScaffold(badge: translate('badgeBiker'))`: fields → `KTextField` (`autofillHints: [AutofillHints.username]` / `[AutofillHints.password]`, wrapped in `AutofillGroup`), remember toggle → `SwitchListTile.adaptive` row (keep existing remember logic), primary → `KButton(loading: state is BikerLoginLoading)` replacing `LoadingWidget`, secondary → `KButton.text` "Forgot password?" → `PhoneNumberScreen`. Keep the existing `BlocConsumer` listener body unchanged.
- [ ] **Step 4:** Same pattern for `phone_number.dart` (phone field + country code), `otp_screen.dart` (`PinCodeWidget` restyled: cells 48×56, radius 14, fill `KColors.fill`, focused border brand; resend timer as `KButton.text`), `update_password.dart` (two password fields), `on_boarding_screen.dart` (full-bleed image + bottom glass sheet with title/subtitle, page dots, `KButton` Next/Get started, "Skip" `KButton.text` top-trailing; image uses `BoxFit.cover` with `Alignment.center`).
- [ ] **Step 5:** Run Biker tests → PASS; `flutter test` and `flutter analyze` (0 errors) in B.
- [ ] **Step 6:** Build and install on both simulators: `flutter build ios --simulator --debug --flavor dev -t lib/main_dev.dart`, `xcrun simctl install <iPhone 18 Pro / iPhone Duo> build/ios/iphonesimulator/Runner.app`, launch, screenshot login (light, English) and with `xcrun simctl ui <device> appearance light`. Save screenshots to `docs/screens/biker/` (`login-iphone18pro.png`, `login-duo-outer.png`).
- [ ] **Step 7: Commit** B `feat(biker): auth screens on Kleano design system`.

### Task 7: User auth screens

**Files:**
- Modify: `U/lib/modules/on_boarding/on_boarding_screen.dart`, `choose_register.dart`, `U/lib/modules/Auth/screens/log_in_screen.dart`, `sign_up_screen.dart`, `otp_screen.dart`, `U/lib/modules/Auth/widgets/pin_code.dart`, `U/lib/modules/profile/screens/profile_account/edit_phone_number/otp_edit_phone.dart`
- Modify: `U/assets/i18n/en.json`, `ar.json`
- Test: `U/test/auth/user_auth_screens_test.dart`

**Interfaces:**
- Consumes: Task 3–5 components; existing `AuthCubit`/`AuthState` (`sendOTPStatus`, `signUpStatus`, `RequestStatus`), `FcmToken.get()`, `AppsFlyerService.logEvent`, `OtpScreen(phone:, fcmToken:, isSignup:)`.

New strings: `welcomeBack` (as Task 6); `userLoginSubtitle`: "Enter your phone number to continue" / "أدخل رقم جوالك للمتابعة"; `createAccount`: "Create your account" / "أنشئ حسابك"; `continueAsGuest` already exists.

- [ ] **Step 1: Failing tests:** choose-register shows Sign up (primary), Log in (secondary), Continue as guest (text) and the guest tap calls `popALlAndPushPage` target `MainNavigationScreen` (assert via a `NavigatorObserver`); login: phone field with country code prefix, Continue pinned above keyboard on 375×667; sign up: name/phone/email fields, invalid email shows error; OTP: code field with `oneTimeCode` autofill.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Rebuild the screens on `KAuthScaffold` / `KButton` / `KTextField` keeping every listener/cubit call. `choose_register.dart` keeps its full-bleed photo with the three buttons in a bottom glass area (approved look); fix: the FCM token fallback string `"Notifications is Unaccessible"` is unchanged in this plan (BE item).
- [ ] **Step 4:** `otp_edit_phone.dart` uses the same OTP layout via `KAuthScaffold(showBack: true)`.
- [ ] **Step 5:** Run tests → PASS; full `flutter test` + `flutter analyze` (0 errors) in U.
- [ ] **Step 6:** Build, install on iPhone 18 Pro and iPhone Duo, screenshot choose-register, login, OTP → `docs/screens/user/`.
- [ ] **Step 7: Commit** U `feat(user): auth screens on Kleano design system`.

### Task 8: Stage verification + Android + docs

**Files:**
- Modify: `docs/design-system.md` (Screens → Auth with screenshots), `UPGRADE_REPORT.md` (section "E2. Redesign stages 1–2")

- [ ] **Step 1:** `U/tool/sync_design.sh --check` → exit 0.
- [ ] **Step 2:** In U and B: `flutter analyze` (0 errors), `flutter test` (all pass), `flutter build apk --debug --flavor dev -t lib/main_dev.dart` (✓ Built), `flutter build ios --simulator --debug --flavor dev -t lib/main_dev.dart` (✓ Built).
- [ ] **Step 3:** Android screenshots of the Biker login and User choose-register/login if an emulator is available (`flutter emulators`); if none is installed, record "Android not visually verified" in the report rather than claiming it.
- [ ] **Step 4:** Add the screenshots to `docs/design-system.md`; publish the doc as a shareable page (Artifact) and put its link in the report.
- [ ] **Step 5: Commit** both repos `docs: design system + auth stage report`.
