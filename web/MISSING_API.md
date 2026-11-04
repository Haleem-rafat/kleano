# What the customer web app still needs

Things the web cannot finish on its own: a backend change, a key, or a decision. Nothing here was
worked around by inventing fields or changing `backend/`.

## Payments

| Gap | Today on the web | What it needs |
| --- | --- | --- |
| **Card (Moyasar)** | Not offered. `pay-order`, `pay-subscription` and `users/wallet/topup` take raw card numbers in `paymentDetails`, and the web must not handle those. | A Moyasar hosted form: the browser pays Moyasar directly and the backend receives only a payment id (`token` or `given_id`). The backend's three endpoints need to accept that instead of `paymentDetails`. |
| **Apple Pay** | Not offered. | Moyasar's Apple Pay on the web, plus Apple domain verification. `pay-order` already takes `applePaymentId`. Note that `pay-subscription` reads no Apple Pay id, although the app sends `applePayId`. |
| **Tamara, Tabby** | Not offered. | The backend already returns a `paymentUrl` for these. The web would need return pages, because the backend's success and failure URLs are built for the app (`DOMAIN_URL`). |
| **Wallet top-up** | Balance shows; top-up points to the app. With no card, Tamara or Tabby on the web, a web-only customer can't add money. | Any of the above. Tamara and Tabby top-ups are the shortest path since no card data is involved: `POST /users/wallet/topup` with `paymentMethod`. |

So on the web a booking or a plan can only be paid from the wallet or on an existing plan.

## Maps

`NEXT_PUBLIC_GOOGLE_MAPS_KEY` is not set anywhere yet. It needs the Maps JavaScript API and the
Geocoding API, restricted to the site's domains. Use a separate key from the phone apps', since this
one is public in the page.
Without it:

- **Add a saved place** shows a clear state and points to the app. New customers can't add a first
  place on the web, so they can't book there until they do.
- **Guest catalogue** can't find the country and asks them to log in.
- **Live tracking** still shows stages, biker and contact buttons, and offers a Google Maps link in
  place of the live map.

## Live tracking (Socket.IO)

- **The token and the header.** The gateway reads the token only from the `authorization` handshake
  header (`auth.service.ts authenticateSocketUser`). Browsers can't set that header on a WebSocket,
  so the web uses Socket.IO's polling transport through this site's `/api/live/socket.io`, which adds
  the header from the httpOnly cookie. Accepting `handshake.auth.token` would not by itself help,
  because that also needs the token in page JavaScript. A short-lived ticket endpoint would allow
  real WebSockets.
- **One socket per customer.** `users.socketId` holds one id and each connection overwrites it, so
  **a customer tracking a wash on the web stops receiving live events in the phone app**, until the
  phone reconnects, and the other way round. It needs a Socket.IO room per user.
- **A socket without the header can crash the handler.** `authenticateSocketUser` calls
  `.split` on a missing header, inside an async connection handler. The web always sends it, but
  anyone can open that socket. Worth fixing in `backend/`.

## Notifications

- **Web push isn't set up.** `fcmToken` is a `web-…` placeholder per browser, so the backend tries to
  send to a token that doesn't work and later drops it. Real push needs Firebase web config, a VAPID
  key and a service worker. The on/off switch (`notification-permission`) works and applies to the
  phone app.

## Backend rules to check

- **Phone change has no verification.** `PATCH /users/phone-number` changes the login number
  immediately, with no code to the new phone. A mistyped number locks the customer out, and a stolen
  session can take over the account. The app has this repository method but no screen for it. The
  web has the screen you asked for, with a confirmation step. It should send a code first.
- **Cancel while waiting for a biker.** The app offers cancel on `WAITING_FOR_BIKER_BY_ADMIN`, but
  `orderStatusValidator.ts` doesn't allow `CANCELLED_BY_USER` from that status, so it fails. The web
  matches the app and shows the backend's message.
- **Cancelling a `SCHEDULED` order** would throw inside the validator, because that status isn't in
  `StatusHirarchy`. Neither the app nor the web offers it.
- **`userOS`** only has `ANDROID` and `IOS`. The web leaves it out, so web bookings can't be told
  apart in reports. It needs a `WEB` value.
- **`order-details/:orderId`** has no owner check, so any signed-in user can read any order by id.
