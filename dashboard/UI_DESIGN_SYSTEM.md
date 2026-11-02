# Kleano admin dashboard — design system

The dashboard uses the same brand as the Kleano apps
(design system page: https://claude.ai/artifact/CW6q57miq9LELeaHnCxeCk).
Every page, dialog, sheet and form is built from the tokens and components below.

## Tokens

Defined as HSL variables in `src/index.css` (`:root` and `.dark`) and mapped in
`tailwind.config.js`. Use only these colour classes:

| Use | Classes |
| --- | --- |
| Page / surface | `bg-background`, `bg-card`, `bg-muted` |
| Text | `text-foreground`, `text-muted-foreground` |
| Brand (#543063) | `bg-primary`, `text-primary`, `bg-primary/10`, `bg-accent` |
| Status | `success`, `warning`, `destructive` (+ `/10` tints for chips) |
| Lines | `border-border`, `border-input`, `ring-ring` |

Radius comes from `--radius` (`rounded-lg`, `rounded-md`, `rounded-sm`). Font is the
system stack (`font-sans`).

**Never**: Tailwind palette colours (`gray-*`, `blue-*`, `green-*` …), `bg-white`, hex
values in classes, gradients on headers or buttons, class names built at runtime
(`` `bg-${color}-500` `` never renders).

## Components (`@UI/Index`)

- `PageHeader` — page title, subtitle and actions.
- `SectionCard` — titled card for a group of content; `StatCard` — KPI tile.
- `Button` — `primary`, `secondary`, `tertiary`, `success`, `danger`, `dangerOutline`.
- `MainStatusChipe` — every status label and colour; don't style statuses inline.
- `MainSelect`, `MainInput`, `MainPhoneNumberInpute`, … for form fields.
- shadcn primitives in `src/shadecn/components/ui` (Dialog, Sheet, Table, Tabs …).

## Form controls and popups

- Every control uses `fieldClass` from `src/shadecn/lib/field.ts`: 40px high, `border-input`,
  `bg-card`, primary border plus a soft glow on focus. `Input`, `SelectTrigger`, `Textarea`,
  `MainSelect`, `Combobox`, the date picker, colour and phone inputs all use it, so don't
  restyle them per page.
- Dropdown panels use `popupSurface` and their rows use `popupItem` (accent highlight; the
  selected row is primary with a check).
- **Sheets: only `FormSheet`** (`@UI/Index`). It floats (inset 12px, rounded), pins the title,
  pads and scrolls the body, and pins the footer. Put a form's submit buttons in
  `<SheetActions>`; it sits at the bottom of the sheet and never covers fields.
  Importing `ui/sheet` in a page is a lint error. Inside a sheet, never use `h-screen`,
  your own `overflow-y-*` scroll, or `absolute bottom-0` bars.
- In a `DataTable`, a column with id `actions` / `action` / `delete` stays pinned to the end
  edge, so row actions are always visible.

## Validation

- Every form has a yup schema built from `v` in `src/app/utils/validation.ts`
  (`text`, `price`, `positive`, `count`, `percent`, `phone`, `digits`, `password`, `url`,
  `bilingual`, `picked`, `options`, `file`). No form submits without a resolver.
- Messages are `validation.*` i18n keys; `FormMessage` translates them (en/ar), including
  nested fields such as `{ en, ar }`.
- Every input has a label and a placeholder. Number fields start empty, never "undefined"
  or 0.

## Page kit (every page)

- `PageHeader`: title (a real `h1`), one-line description, actions; details pages add
  `onBack` and a `leading` avatar or icon.
- `SectionCard`: every content group. No icon badges or extra header strips inside cards.
- `InfoList`: label/value pairs on details pages (never grey boxes per value).
- Stat tiles: `rounded-lg border bg-card px-4 py-3`, small label, `text-lg` value.
- `CityAvailability`: where a service, plan or add-on is offered (pause/resume/add).
- Tabs and switches: shared `Tabs` and `Segmented` (`@UI/Index`) use one boxed style
  (`segmentGroup`/`segmentItem` in `field.ts`): a bordered box, selected option filled
  with primary, scrolls sideways and keeps the selected tab in view. Use `Segmented` for
  view toggles and 2–5 quick filters instead of a dropdown.
- Filter bars: a `grid gap-2 sm:grid-cols-2 lg:grid-cols-4` under the tabs, controls full
  width, search fields with a leading icon. Changing a filter resets to page 1.
- Tailwind is 3.3: no numeric `min-w-*`, `max-w-*`, `min-h-*` or `size-*`; use brackets
  (`min-w-[8rem]`) or `h-4 w-4`.
- `RichTextEditor`: long formatted text (Terms). The app renders the saved HTML.

## Patterns

- Lists: `PageHeader` + filter row + `Table` in a card; rows that open details get
  `cursor-pointer hover:bg-primary/10`.
- Details: `PageHeader` with back button + `SectionCard`s.
- Create / edit forms open in a `Sheet`. Put the form inside
  `<SheetDescription asChild><div>…</div></SheetDescription>` — a form inside the
  default `<p>` is invalid HTML.
- Every `Dialog` needs a `DialogTitle` (use `sr-only` if it shouldn't show).
- Destructive actions confirm with `AlertDialog` and a `danger` button.
- All text through `t()`, keys in both `en` and `ar` locales.

## Performance

- Heavy libraries (Leaflet, FullCalendar, charts) load lazily with their route.
- Vendor chunks are split in `vite.config.ts` (`VENDOR_CHUNKS`).
- The PWA precaches only the app shell.

## Checks before committing

`npx tsc --noEmit`, `npx eslint src` (0 errors), `npx vite build`, then open the page
and confirm no console errors.
