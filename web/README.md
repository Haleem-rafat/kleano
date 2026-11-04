# Kleano website

Next.js 16, React 19, Tailwind 4. Landing page, the customer web app (`/[locale]/app`) and the biker
web app (`/[locale]/biker`), in Arabic (right to left, default) and English, dark and light.

```bash
npm install
cp .env.example .env.local   # optional, see below
npm run dev                  # port 4100
npm run typecheck && npm run lint && npm run build
```

`KLEANO_API_URL` defaults to the **live** backend, so anything you do in a signed-in browser changes
real data. Point it at a local backend while developing. `NEXT_PUBLIC_GOOGLE_MAPS_KEY` turns on the
maps; see `MISSING_API.md` for what happens without it.

## Customer web app

Feature parity with `customer-app/`: same endpoints, fields, validation and wording.

- **API:** `lib/kleano/domains/*` has one typed client and its TanStack Query hooks per domain.
  `lib/kleano/queries.ts` re-exports them.
- **Forms:** Zod and React Hook Form. `lib/validation.ts` ports `validator.dart`.
- **Words:** `lib/app-dictionary.ts`, taken from `customer-app/assets/i18n`.
- **Building blocks:** `components/app/kit.tsx` (sheet, confirm, searchable picker, rows, segmented,
  skeletons) and `components/app/bits.tsx` (titles, money, status, empty and error states).
- **Layout:** `components/app/app-shell.tsx`. Sidebar and top bar on desktop, icon rail on tablet,
  floating dock on phones. Bookings is master and detail on desktop and a slide-over on tablet.
- **Keyboard:** Cmd+K or Ctrl+K and `/` open the palette. Esc closes any panel.
- **Glass:** only the phone dock, the top bar and controls floating over a map. Content is solid.
  The dock uses Aceternity's `liquid-glass` with a card tint for contrast; under reduced motion it is
  plain frosted glass.

### Auth and tokens

Tokens live in httpOnly cookies. `app/api/auth/*` logs in and signs up.
`app/api/kleano/[...path]` forwards every other call with the token, refreshes it, and blocks admin
routes. Page JavaScript never sees a token.

### Live tracking

The backend's Socket.IO gateway reads the token from the `Authorization` handshake header. A browser
can't set headers on a WebSocket, so `lib/kleano/live.ts` uses the **polling** transport through
`app/api/live/socket.io`, which adds the header from the cookie and forwards only `/socket.io/`,
only for a signed-in customer.

The trade-offs: polling sends more requests than a WebSocket, each one through this server, so it
only runs on the tracking screen. Each long poll lasts up to about 25 seconds, so a host's function
time limit must be longer than that. It assumes one backend instance, or sticky sessions, as Socket.IO
polling always does. Live events also go to only one connection per customer: see `MISSING_API.md`.

### Payments

The web never handles card numbers. Bookings and plans are paid from the wallet, or on a plan.

## Testing without the live backend

Don't type real OTPs or passwords while `KLEANO_API_URL` points at the live server. To see signed-in
screens, use fake JWT cookies (`kleano_customer_access`, `kleano_customer_refresh`) with a future
`exp` and answer `/api/kleano/*` with fixtures in the browser, or point `KLEANO_API_URL` at a local
mock.
