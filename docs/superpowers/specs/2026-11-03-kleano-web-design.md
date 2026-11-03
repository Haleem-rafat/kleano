# Kleano on the web: landing page, customer web app, biker web app

Date: 2026-11-03. Owner: Haleem Rafat. Status: plan, not started.
Landing preview (approved direction to build from): https://claude.ai/artifact/PKDd4nCbUEE6sLRbSR4Nca

## Why

Today Kleano is only in the iPhone and Android apps, plus a one-file static `landing/` page.
The owner wants one website where people land, read about Kleano in Arabic or English, and
then use Kleano in the browser with the same experience as the apps: customers book and
follow washes, bikers handle their orders. Start with the landing page.

## Goals

- One Next.js site in the monorepo (`web/`) that holds the landing page, the customer web
  app and the biker web app.
- Arabic and English everywhere, with right-to-left layout for Arabic. Light and dark mode,
  following the device by default, with a toggle.
- Same look as the apps: Kleano's colours, type scale, spacing, radii, logo, photos and
  wording, taken from `customer-app/lib/core/design/` and the apps' own copy.
- Same behaviour as the apps: the web calls the same backend endpoints with the same
  request and response shapes.
- A written API map: every screen, the endpoint it calls, and the data it shows.

## Non-goals

- No backend changes. The web uses the live API as it is. (The backend already allows
  requests from any website: `enableCors({ origin: true })` in `backend/src/main.ts`.)
  Anything the web needs from the backend goes on a list for the backend dev.
- No new design language. The web follows the app design system; if a web component is
  missing, it is added to the web design layer and documented, the same rule as the apps.
- No admin features. The admin dashboard stays in `dashboard/`.

## Anti-goals (would count as failure even if it works)

- A generic template look, or a site that feels like a different brand from the apps.
- English-first layout with Arabic bolted on (mirrored icons wrong, mixed alignment).
- Copying API paths by hand into many files so they drift from the apps.
- Slow first load: the landing page must be fast on a mid-range Android phone in Egypt.

## Decisions

| Area | Choice | Why |
|---|---|---|
| Framework | Next.js (App Router, TypeScript), in `web/` | Owner's choice. Server-rendered landing for speed and search. |
| UI kit | Tailwind CSS + shadcn/ui, themed with Kleano tokens | shadcn gives accessible parts we restyle; no foreign look. |
| Tokens | `web/design/tokens.css` generated from `tokens.dart` by a script | One source of truth, the same as `sync_design.sh` for the apps. |
| Languages | `/ar/...` and `/en/...` routes (next-intl); Arabic is the default for Egypt | URL per language is better for search and sharing. |
| Theme | next-themes: system, light, dark | Matches the apps and the landing preview. |
| Fonts | Readex Pro (headings) + IBM Plex Sans Arabic (text), via `next/font` | Both cover Arabic and Latin; same pairing as the preview. |
| Data | TanStack Query in client screens; server components for the landing | Caching, retries and loading states like the apps' BLoCs. |
| Auth | Phone + OTP (customer), phone + password (biker), token kept in an httpOnly cookie | The token never sits in page JavaScript. |
| API access | Next.js route handlers at `/api/kleano/*` forward to `kleano-backend.onrender.com/api/*` and add the token | Keeps the token server-side; one place for errors and language headers. |
| Live updates | socket.io-client to the same gateways the apps use (orders, bikers) | Same live tracking as the apps. |
| Maps | Google Maps JavaScript API | The apps use Google Maps; same places and pins. |
| Skills used while building | `vercel:nextjs`, `vercel:shadcn`, `vercel:react-best-practices`, `vercel:next-cache-components` | Official Next.js guidance. The aisdkagents.com skills are paid AI-agent kits, not UI kits, so they don't apply. |

## Site map

```
/[locale]                      Landing page (from the preview)
/[locale]/login                Customer log in / sign up (phone + OTP)
/[locale]/app                  Customer home: services, offers, recent bookings
/[locale]/app/book             Booking: service, add-ons, car, address, date and time, payment
/[locale]/app/bookings         Current and past washes; /[id] details and photos
/[locale]/app/track/[id]       Live tracking
/[locale]/app/cars             My cars
/[locale]/app/plans            Plans and subscriptions
/[locale]/app/wallet           Wallet, points, promo codes
/[locale]/app/profile          Profile, saved places, language, log out
/[locale]/biker/login          Biker log in
/[locale]/biker                Biker home: new requests, today's orders
/[locale]/biker/orders/[id]    Order details, change status, upload photos
/[locale]/biker/schedule       Working days and areas
/[locale]/biker/earnings       Earnings and completed washes
/[locale]/biker/profile        Profile, notifications, settings
```

## API map (to be completed in phase 2)

The apps' endpoints live in `customer-app/lib/api/api_path.dart` (49 paths) and
`biker-app/lib/api/api_path.dart` (25 paths). Phase 2 turns these into
`web/lib/api/paths.ts` with a script, so the web and the apps can't drift, and writes
`docs/web-api-map.md` with one row per screen:

| Screen | Method + path | Sends | Shows |
|---|---|---|---|
| Customer home | `GET /washing-services/user/all` (guest: `/guest/all`) | latitude, longitude, country, type | service cards |
| Plans | `GET /plans/user/all` (guest: `/guest/all`) | latitude, longitude, country | plan cards |
| … | one row for every call in `api_path.dart` | | |

Backend controllers the web will call (from `backend/src`): auth, users, cars, vehicles,
locations, washing-services, add-ons, plans, subscriptions, booking-availabilities,
orders/user, orders/biker, payments/user, wallet, points, promo-codes, banners,
notifications, terms, contact-info, bikers, biker/schedule, user/biker-schedules.

## Phases

1. **Landing page in Next.js.** Create `web/`, port the preview (both languages, both
   themes), add page titles, descriptions, social cards, `hreflang`, sitemap, real App Store
   and Google Play links. Then **delete the old `landing/` folder** and update
   `.claude/launch.json`, `README.md`, `CLAUDE.md` and `docs/HANDOFF.md`.
2. **Shared foundation.** Token generation script, the `/api/kleano` forwarding layer,
   auth cookies, typed API client generated from `api_path.dart`, language and theme
   setup, web versions of KButton, KTextField, KPickerField, KCard, KListRow,
   KStatusChip, KSegmented, KDialog and sheets. Write `docs/web-api-map.md`.
3. **Customer web app**, in this order: log in, home, booking, bookings and tracking, cars,
   plans, wallet, profile.
4. **Biker web app:** log in, home and requests, order details and status, schedule,
   earnings, profile.
5. **Launch:** domain, hosting, analytics, error tracking.

Each phase ends with: type check, lint, tests, a check in a phone-size and a desktop
browser in Arabic and English, light and dark, then a commit. No push or deploy without
the owner's OK.

## Things the owner or the backend dev must provide

- Domain name and where the site is hosted (Vercel suggested; deploying needs your OK).
- Real App Store and Google Play links.
- A Google Maps JavaScript key for the website's domain.
- Payment on the web: Moyasar publishable key and domain set-up; Tabby and Tamara web
  redirects; Apple Pay on the web needs domain verification.
- Backend list (no backend changes from us):
  - Services, plans and add-ons are refused unless the country is "Saudi Arabia", and
    no area with active bikers covers the tested Cairo or Riyadh points. Until this is
    sorted, the customer web app will show the same empty services as the phone apps.
  - Optional: web push notifications need a Firebase web app and VAPID key.

## Limits of the biker app on the web

A browser can't track location in the background or play the new-order sound while the
tab is closed. The biker web app is for bikers at a computer or with the tab open; the
phone app stays the main tool for bikers on the road.

## Left to the builder

Folder layout inside `web/`, component names, test tooling, and exact breakpoints, as long
as the decisions above hold.
