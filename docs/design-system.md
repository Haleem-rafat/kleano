# Kleano Design System

One design system for both Kleano apps (**User** and **Biker**), on iOS and Android.
Source of truth: `Kleano-Flutter-dev/lib/core/design/` (copied byte-identical into the Biker app by `tool/sync_design.sh`).

## 1. Principles

- **Content first, controls float.** Following Apple's Liquid Glass HIG, glass is the *controls layer* (tab bar, toolbars, floating buttons, sheets). Content stays opaque and readable.
- **Purple means "act".** The brand purple is for buttons, selection and highlights, never for large bars or backgrounds (the auth brand header is the one exception).
- **Direction comes from the app, not the phone.** Arabic can run on an English iPhone, so native glass buttons receive `rtl` from Flutter and set the layout-direction trait; that is what flips `chevron.backward`.
- **Native on each platform.** iPhone uses Apple's real Liquid Glass (`UIGlassEffect`, glass `UIButton`s, `UITabBar`). Android uses Material 3 Expressive with the same colours, sizes and shapes.
- **One system everywhere.** No one-off colours, font sizes or radii: use the tokens below.
- **Every screen shape.** Phones, landscape, iPhone Duo folded/unfolded, iPad and Android foldables; English and Arabic (RTL).

## 2. Tokens (`tokens.dart`)

### Colour (`KColors`)

| Token | Light | Dark | Use |
|---|---|---|---|
| `brand` | `#543063` | `#B88CD0` | Primary actions, selection, tint |
| `brandLight` | `#8E5BA6` | `#8E5BA6` | Gradients, secondary accents |
| `background` | `#F2F2F7` | `#000000` | Screen background |
| `surface` | `#FFFFFF` | `#1C1C1E` | Cards, sheets, lists |
| `text` | `#1C1C1E` | `#FFFFFF` | Primary text |
| `textSecondary` | `#6E6E73` | `#98989F` | Secondary text, labels |
| `success` | `#34C759` | `#30D158` | Completed, online |
| `warning` | `#FF9500` | `#FF9F0A` | In progress, attention |
| `error` | `#FF3B30` | `#FF453A` | Errors, cancelled, destructive |
| `separator` | `#3C3C43` 29% | `#545458` 60% | Row hairlines |
| `fill` | `#787880` 16% | `#787880` 36% | Fields, segmented controls, secondary buttons |

Read colours with `KColors.of(context)` so dark mode works.

### Type (`KType`)

Platform fonts: SF Pro / SF Arabic (iOS), Roboto / Noto Arabic (Android). Styles carry no colour; set it where used.

| Style | Size / weight | Use |
|---|---|---|
| `largeTitle` | 34 / w800 | Screen titles ("Welcome back") |
| `title` | 22 / w700 | Section titles |
| `headline` | 17 / w600 | Row titles, card titles, button labels |
| `body` | 17 / w400 | Body text |
| `subhead` | 15 / w400 | Secondary info |
| `footnote` | 13 / w400 | Field labels, metadata |
| `caption` | 12 / w400 | Small print |

Text scales with the user's font size, clamped to 0.85–1.35.

### Spacing, radius, motion

- **Spacing (`KSpace`):** 4, 8, 12, 16, 20, 24, 32. Minimum tap target **44 pt**.
- **Radius (`KRadius`):** field 14, card 22, dialog 30, sheet 34; buttons are capsules. All corners are continuous (superellipse).
- **Motion (`KMotion`):** fast 200 ms, normal 300 ms, slow 400 ms, curve `easeOutCubic`. `KMotion.of(context, d)` returns zero when Reduce Motion is on.

## 3. Components

### Button (`KButton`)

| Variant | Use | iOS | Android |
|---|---|---|---|
| `primary` | The one main action of a screen (Log in, Accept request) | `UIButton` `.prominentGlass()`, tinted brand, white label | `FilledButton` |
| `secondary` | Alternative actions (Details, Navigate) | `UIButton` `.glass()`, brand label | `FilledButton.tonal` |
| `text` | Low-emphasis links (Forgot password?, Skip) | `CupertinoButton`, brand label | `TextButton` |

- Height 50 (iOS) / 52 (Android); text buttons 44. Full width by default (`expand: false` to hug content).
- **One primary per screen.**
- `loading: true` shows a spinner inside the capsule and **ignores taps** (no double submits).
- Labels are one line and ellipsize; they never overflow, even at text scale 1.35.

### Text field (`KTextField`)

- Label above the field (footnote, secondary colour); filled field (`fill` token), radius 14, 2 px brand border when focused, red border + message below on error.
- Passwords: `obscure: true` adds a show/hide eye button.
- Always set `keyboardType` and `autofillHints` (username, password, phone, one-time code) so iOS/Android autofill works.
### Search field (`KSearchField`)
Platform search: Apple's `CupertinoSearchTextField` on iOS, Material 3 `SearchBar` on Android. Never an outlined form field. Used in `KPickerField` and map search.

### Card (`KCard`)
Surface colour, radius 22 continuous corners, soft shadow in light mode, none in dark. Use for orders, vehicles, plans, any grouped content. Optional `onTap` gives the whole card a ripple/highlight.

### Status chip (`KStatusChip`)
| Status | Use | Label colour (light) |
|---|---|---|
| `success` | Completed, online, paid | `#1F8A3D` |
| `warning` | On the way, in progress, pending | `#C25E00` |
| `error` | Cancelled, failed | `#D70015` |
| `brand` | Accepted, new | brand |
| `neutral` | Scheduled, info | secondary text |
Background is the status colour at 12%. Labels use darker shades so they pass contrast.

### Segmented control (`KSegmented`)
2–4 options that switch the content below (Active / Completed). iOS: Apple's sliding segmented control. Android: Material 3 `SegmentedButton`. Full width.

### List row (`KListRow`)
Settings and profile lists. At least 44 pt tall; title + optional subtitle, leading icon, trailing widget, chevron (mirrors in Arabic) when it opens another screen.

### Empty / loading / error states (`KEmptyState`, `KLoadingState`, `KErrorState`)
- **Empty:** icon, title, optional message and one action.
- **Loading:** platform spinner (iOS activity indicator / Material progress), centred. Prefer this over full-screen shimmer.
- **Error:** message plus a retry button; the retry label is Flutter's built-in localized "Refresh".
### Auth scaffold (`KAuthScaffold`)

Used by every auth / entry screen (login, sign up, OTP, phone, new password).

```
┌──────────────────────────────┐
│ ‹ (glass back, optional)     │  brand header: purple gradient,
│                              │  white logo + badge ("Biker")
│ KleanO  Biker                │  shrinks to 96pt when the keyboard opens
╭──────────────────────────────╮
│ Welcome back                 │  large title
│ Log in to start receiving…   │  subtitle
│ Username  [             ]    │  form fields (scrolls)
│ Password  [          👁 ]    │
│ Remember me            (●)   │
│                              │
│ [        Log in         ]    │  primary action — pinned
│        Forgot password?      │  secondary (text) action
╰──────────────────────────────╯
```

- The actions are **outside the scroll view** and padded by the keyboard height (or the home-indicator inset), so the primary button is never hidden or cut off.
- The back button and logo sit on the leading side and mirror in Arabic.
- Works on iPhone Duo's outer display (kept clear of the side status bar) and in landscape (form scrolls).

## 4. Platform rendering

| Component | iOS | Android |
|---|---|---|
| Primary button | `UIButton` `.prominentGlass()` tinted brand | `FilledButton` |
| Secondary button | `UIButton` `.glass()` | `FilledButton.tonal` |
| Tab bar | `UITabBar` (native glass) | Floating glass capsule (Flutter) |
| Swipe action (`KSwipeAction`) | Same on both: drag the thumb to the end to confirm a step that must not fire on a stray tap. Mirrors in Arabic; a plain button for screen readers | |
| Glass surfaces | `UIGlassEffect` | Flutter blur + tint |

## 5. iPhone Duo and regular width

- **Folded (outer display):** iOS reports the side status bar as a right safe-area inset; `SystemBarInset` keeps every page clear of it.
- **Unfolded, wider than tall:** the tab bar becomes a glass sidebar (`GlassSidebar`). Unfolded portrait keeps the bottom tab bar.
- **Fold line:** `FoldScope` feeds the fold into `MediaQuery.displayFeatures`; dialogs, sheets and the tab bar avoid it.

## 6. Accessibility

- Contrast: text on surfaces meets WCAG AA; status chips use darker label shades.
- Dynamic Type / font scale supported (clamped 0.85–1.35); layouts wrap instead of clipping.
- Reduce Motion and Reduce Transparency (glass becomes opaque) are respected.
- Every control has a semantic label; tap targets are at least 44 pt.

## 7. Screens

(Filled in as screens are redesigned, with before/after screenshots.)
