# Kleano backend

NestJS 9 + MongoDB (Mongoose) API for the customer app (`../customer-app`), the biker app
(`../biker-app`) and the admin dashboard (`../dashboard`). Live at
`https://kleano-backend.onrender.com/api/` (global prefix `api/`), which is what both app
flavors use today.

Open security issues: `../docs/backend-review.md`. Read it before changing auth, orders,
wallet or payments.

## Run

```bash
npm install
npm run start:dev      # watch mode, port 3000 (PORT overrides)
npm run build && npm run start:prod
```

Needs `backend/.env` (not in git, live secrets): `DB`, JWT secrets, Firebase, Moyasar,
Tamara, Tabby, Qoyod, OurSMS and mail settings. On start it creates the super admin if
missing (`AdminService.injectSuperAdmin`).

## Check

```bash
npx tsc -p tsconfig.build.json --noEmit
npm run lint           # note: runs eslint --fix
npm test               # jest, *.spec.ts under src/
```

## Layout (`src/`)

- `auth/` login, OTP, refresh tokens, guards (`UserAuthGuard`, `IsAdminGuard`, `SuperAdminGuard`)
- `user/`, `bikers/`, `admin/` accounts; `vehicles/`, `car/` (brand/model seed), `locations/`
- `orders/` user, biker and admin order flows, `gateway/order.gateway.ts` (socket.io)
- `payments/` Moyasar, Tamara and Tabby webhooks; `tamara/`, `tabby/`, `wallet/`, `points/`, `promo-code/`
- `plans/`, `subscriptions/`, `washing-services/`, `add-ons/`, `services-icons/`
- `city/`, `area/`, `booking-availability/`, `biker-schedule/`, `segments/`
- `notifications/` FCM pushes; `banners/`, `contact-info/`, `terms-conditions/`
- `qoyod/` accounting sync (see `QOYOD_INTEGRATION.md`); `migrations/` one-off scripts
- `common/` errors, email, SMS OTP, Firebase, pagination

## Deploy

`.github/workflows/push.yml` is the **production** deploy: a push to the `prod` branch of the
original backend repo builds a Docker image (with `.env` fetched from S3) to GHCR and redeploys
it on the VPS. It must not be triggered from here. GitHub only runs workflows from a repo's
root `.github/`, so inside `backend/` of this monorepo it is inert; keep it that way (don't
move it to the root, don't add a `prod` branch).
