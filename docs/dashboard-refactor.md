# Kleano admin dashboard — design-system refactor plan

Project: `kleano-client-admin-web-development/` (Vite + React 18 + TypeScript,
shadcn/ui on Radix, Tailwind, Redux Toolkit, TanStack Table, FullCalendar, Google Maps).
Run: `.claude/launch.json` → "dashboard" (port 4000). Login needs the owner's admin
account (live backend): never type it; ask the owner to log in in the browser pane.

## Audit (2026-11-02)

| Area | Finding |
|---|---|
| Theme | shadcn token classes (`bg-card`, `text-muted-foreground`, `border-border`, `ring-ring`, `bg-muted`, `bg-accent`) were **undefined** → unstyled. **Fixed** in `fa3c36f` (tokens = mobile design system values, light + dark). |
| Styling debt | 56 files use ad-hoc `slate-*` / gradient classes; 38 hard-coded hex colours; `UI_DESIGN_SYSTEM.md` prescribes a different gradient colour per section (blue, purple, green, emerald, orange, indigo) — the main reason pages look busy. |
| Types / lint | `tsc` 0 errors. ESLint 773 problems: 479 formatting, ~200 unused vars/imports, 47 `any`, 3 errors (2 import order, 1 empty interface). |
| Crash safety | Route `ErrorBoundary` exists (`src/shared/Layouts/ErrorBoundary.tsx`); 30 lazy routes. Logged-in audit 2026-11-02: **all 21 list routes load with 0 console errors** (admin, users, bikers, order, booking, booking-calendar(-2), notification, transaction, washing-services, plans, add-ons, promo-code, segments, pointes, assign-order, icons, terms, contact-info, app-banner, profile, dashboard). Crashes must be in detail pages / actions / specific data — ask the owner for steps. |
| Speed | Main bundle `index-*.js` **794 kB** (min, before gzip) loaded on every page; `chart` 359 kB, `BookingCalendar` 324 kB, `OrdersList` 175 kB. |

## Rules (same as the apps — see `Kleano-app/CLAUDE.md`)

- One accent: brand purple (`primary`). Status colours only for status (success,
  warning, destructive). No gradients, no per-section colours.
- Only theme tokens: `bg-background`, `bg-card`, `text-foreground`,
  `text-muted-foreground`, `border-border`, `bg-accent`, `ring-ring`. No `slate-*`, no hex.
- shadcn primitives only: `Button`, `Card`, `Table`, `Badge`, `DropdownMenu`, `Sheet`,
  `Dialog`, `AlertDialog` (all destructive confirms), `Select`/`Command` pickers,
  `Tabs`, `Skeleton`, `Form`. Lucide/heroicons at 16–20px, one set.
- Every list/page has designed loading (Skeleton), empty and error (retry) states.
- Status words and colours match the apps' `KStatusChip`.

## Status (2026-11-02) — all phases done

All commits are in `kleano-client-admin-web-development`, not pushed.

- **Tokens** `fa3c36f`. **Shared layer** `3919ae5`: `PageHeader`, `SectionCard`, `StatCard`, token status chips and Button.
- **Pages**: Dashboard `3919ae5`; Orders `4a4191c`/`b32ae3a`; Promo codes `e76d8f4`; Users, Bikers, Booking, Calendar, Assign orders, Admins `d9e6b0d`; every other page `2ed8f29`.
- **Speed** `3f352e9`, `91b6266`:
  - entry chunk 794 → 161 kB, Orders 175 → 15 kB
  - 17 unused packages removed
  - PWA precaches only the app shell
- **Bugs**:
  - export crash, cancelled filter, `[object Object]` services and null-safety crashes fixed
  - forms in sheets no longer sit inside a `<p>` (all 15 sheets)
  - every Dialog has a title
  - all 21 routes and their detail pages load with no console errors
- **Lint** `2ed8f29`: 0 errors, Prettier warnings cleared, unused imports removed. What remains are 232 warnings, mostly enum false positives from base `no-unused-vars`, plus `any`.
- **Docs** `c930aec`: `UI_DESIGN_SYSTEM.md` holds the current rules.

### Possible follow-ups

- Shared `DataTable`, with search, Skeleton rows and an empty state, to replace the per-page tables.
- Turn off base `no-unused-vars` for TS (the TS rule already covers it), then type the remaining `any`s.
- Add a per-route error boundary with retry.
