# Kleano apps — rules for every session

Two Flutter apps share one design system: `Kleano-Flutter-dev/` (customer) and
`Kleano-Biker-Flutter-dev/` (biker). Read `docs/HANDOFF.md` first, then
`docs/design-system.md`. Design system page:
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
  run `tool/sync_design.sh`, and document it — don't style it inline.

## Working rules

- Keep BLoC/cubit calls, navigation and validation unchanged when restyling.
- After changes: `flutter analyze` (0 errors) and `flutter test` in both apps,
  `tool/sync_design.sh --check`, then check on the simulator before saying done.
- Don't type OTP codes or passwords into the app: it uses the live backend.
- Commit in both repos after each verified step; never push.
