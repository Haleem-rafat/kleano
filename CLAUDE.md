# Kleano apps — rules for every session

One repo: two Flutter apps sharing one design system, `customer-app/` and `biker-app/`,
plus `dashboard/` (React admin), `landing/` (marketing page) and `backend/` (NestJS +
MongoDB API, live at `kleano-backend.onrender.com`). Read `docs/HANDOFF.md` first, then
`docs/design-system.md`; for backend work `docs/backend-review.md`. Design system page:
https://claude.ai/artifact/CW6q57miq9LELeaHnCxeCk

## Everything must match the design system (owner's rule)

- Build every screen, sheet, dialog and field ONLY from `lib/core/design/`:
  `KColors`, `KType`, `KSpace`, `KRadius`, `KMotion`, `KButton`, `KTextField`,
  `KPickerField`, `KCard`, `KListRow`, `KStatusChip`, `KSegmented`, `KDialog`,
  `showKSheet`, states, `KAuthScaffold`, `GlassAppBar`/`GlassBackButton`/`GlassTabBar`.
- Never in new or touched code: `AppStyles`, `ColorManager`, `ButtonsShared`,
  `DropdownSearchShared`/`DropdownButton`, hard-coded colours, font sizes or radii,
  `.w/.h/.sp` sizes, gradients on buttons, dashed boxes.
- Dropdowns → `KPickerField` (searchable sheet). Text inputs → `KTextField`.
  Confirmations → `KDialog`. Choice lists → `showKSheet` + `KListRow`.
- Glass is the navigation layer only: tab bar, back and top-bar buttons, controls
  floating over a map. Content, buttons in content (`KButton`), chips, sheets and dialogs
  are solid on both platforms. iOS uses Apple's real Liquid Glass; Android uses the
  Flutter glass in `LiquidGlass` (owner's choice, 2026-10-31), kept cheap. Everything else
  on Android is Material 3: tonal colours, type scale, outlined fields, Material dialogs.
- Performance matters: no timers that rebuild screens, no fixed delays before loading,
  no `BackdropFilter` outside `LiquidGlass`, `const` where possible, sized images.
- Keep the app's own identity: its icons in `assets/svg/`, its photos, its wording.
  No generic placeholder UI.
- If something you need isn't in the design system, add it there (customer app),
  run `customer-app/tool/sync_design.sh`, and document it — don't style it inline.

## Working rules

- Keep BLoC/cubit calls, navigation and validation unchanged when restyling.
- After app changes: `flutter analyze` (0 errors) and `flutter test` in both apps,
  `customer-app/tool/sync_design.sh --check`, then check on the simulator before saying done.
- After backend changes (in `backend/`): `npx tsc -p tsconfig.build.json --noEmit`
  (0 errors), `npm run lint`, `npm test`. Keep response shapes unchanged: the apps and
  dashboard parse them.
- Don't type OTP codes or passwords into the app: it uses the live backend.
- Never commit `backend/.env`, deploy the backend, or call its admin, payment or webhook
  routes on the live server without the owner's OK.
- Commit in the root repo after each verified step; never push.
