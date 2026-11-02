# Backend review — 2026-11-02

Code review of `backend/` (NestJS 9, Mongoose 6, ~35k lines in `src/`), the server both
apps and the dashboard call (`https://kleano-backend.onrender.com/api/`). Read only:
nothing was changed or run against the live server. Line numbers are from this date.

Checks run in `backend/`: `npx tsc -p tsconfig.build.json --noEmit` 0 errors;
`npx eslint "src/**/*.ts"` 10 errors, 53 warnings; `npx jest` 1 suite, 7 tests, all pass
(only the Qoyod customer sync has tests; `test/app.e2e-spec.ts` is the Nest starter);
`npm audit --omit=dev` 76 issues (8 critical, 31 high).

**Confirmed** = the code path was read end to end. **Plausible** = depends on a payment
provider's behaviour that was not checked.

## Fix first (money and accounts)

1. **Moyasar webhook is not verified (confirmed).** `src/payments/payment.controller.ts:10-31`
   has the signature check commented out, and `payment.service.ts:57` trusts the body.
   Anyone can `POST /api/payments/webhook-listener` with `type: payment_paid`,
   `metadata.type: wallet_topup`, any `userId` and a matching `amount` and get wallet credit
   (`processSuccessfulWalletTopUp`, `:735`). The same works with `metadata.orderId` to mark
   any order paid. There is no deduplication on `data.id` for top-ups, so replaying one real
   event credits again. Fix: verify `secret_token` (Moyasar's webhook secret is in the body),
   then fetch the payment from Moyasar's API by `data.id` and use its amount, status and
   metadata, not the request's.
2. **Biker account takeover without a password (confirmed).** `POST /api/auth/bikers/check-phone`
   returns a 10-minute biker access token for any registered biker phone
   (`auth.service.ts:225-238`). `POST /api/auth/bikers/reset-password` accepts that token and
   sets a new password (`:240`). The token also works on every biker endpoint. Fix: send an
   OTP to the phone and issue a single-purpose reset token only after it is verified.
3. **Qoyod admin routes are public (confirmed).** `src/qoyod/controllers/*.ts` have no guards:
   anyone can list, create, edit and delete Qoyod customers (names, phones, emails), products,
   invoices and payments, and start full syncs (`POST qoyod/customers/sync/users`). Fix:
   `@UseGuards(UserAuthGuard, IsAdminGuard)` on all three controllers.
4. **Any user can cancel anyone's order (confirmed).** `cancelOrderByUser`
   (`orders/services/userOrders.service.ts:394`) never compares `order.user` with the caller.
   The same is missing in `payOrder` (`:831`) and `applyUserPoints` (`:621`, spends the
   caller's points on someone else's order). `GET orders/user/order-details/:orderId`
   (`orders/controllers/userOrders.controller.ts:162`) returns any order with its address and
   people. Fix: load the order with `{ _id, user: account.id }`.
5. **Wallet history and balance of any user (confirmed).** `wallet.controller.ts:41` and `:61`
   use `account.id !== userId && !account.role`; every token has a role, so the check never
   fails. `GET wallet/:id` (`:86`) has no owner check at all. Fix: allow only the owner or
   admin roles.
6. **Tamara: unauthenticated checkout proxy and optional signature (plausible).**
   `POST /api/tamara/checkout-session` (`tamara/controllers/tamara.controller.ts`) forwards any
   body to Tamara with the merchant key. A caller can choose the
   `order_reference_id` `wltopup:<userId>:<amount>` with a small real total; on
   `order_approved` the wallet is credited with the amount from the reference
   (`payment.service.ts:800`), which is never compared with what Tamara charged. The webhook
   signature is checked only if the header is present (`:869`). Fix: guard the route, build the
   body on the server, require the signature, compare Tamara's order total.
7. **Wallet double spend (confirmed).** `checkWalletBalanceValid` then `payWithWallet`
   (`user/user.service.ts:225-231`) read, subtract and save. Two payments at once both pass.
   Fix: one `findOneAndUpdate({ _id, walletBalance: { $gte: amount } }, { $inc: … })`.
8. **Payment writes are outside the transaction (confirmed).** The webhook handlers start a
   session, but `topUpWallet`, `paymentsRepository.create` and the Tamara/Tabby helpers don't
   pass it, so an error after the credit leaves the money in the wallet without a payment
   record.

## Auth and OTP

- Wrong OTPs are not counted (`auth.service.ts:478`); only sends are (3 per 30 min,
  `user/services/user-cron.service.ts`). A 6-digit code is guessable within its 10-minute
  life with no rate limit. Add attempt counting and a throttler.
- Test numbers `+201202939672` and `+201284183181` always accept `000000`
  (`auth.service.ts:424`, `:454`, "remove after testing"). Anyone can log in as them on the
  live server.
- Login adds the caller's FCM token to the account before the OTP is checked
  (`auth.service.ts:141-153`): knowing a phone number is enough to receive that user's pushes.
  Move it after `verifyOtp`.
- Suspension is read from the 30-day token (`auth/guards/userAuthentication.guard.ts`), so a
  suspended user keeps access until the token expires; bikers are never checked.
- `ProfileOwnerGuard` always passes for any signed-in user (it compares the user with itself);
  `ProfileOwnerOrAuthClientGuard` lets every biker read every user.
- Socket connect without an `authorization` header throws outside the `try`
  (`auth.service.ts:394`); not checked whether this only drops the socket or logs an
  unhandled rejection.
- Biker routes (`orders/biker/*`) and user routes accept any role's token; they rely on the
  id lookup failing. Add role guards.

## Platform

- CORS allows every origin and header (`main.ts`; tokens are bearer headers, so low risk), and `ValidationPipe` has no
  `whitelist`, so unknown body fields reach Mongoose updates.
- `Dockerfile` copies `.env` into the image; anyone with pull access to the GHCR image gets
  every secret. Pass env at run time instead.
- `backend/.env` holds live secrets (DB, JWT, Firebase, Qoyod, SMS, mail). It is ignored by
  `backend/.gitignore`; keep it out of the root repo.
- Unpaid-order expiry is a `setTimeout` in the request (`userOrders.controller.ts:74`), lost on
  every restart; `orders-cron.service.ts` (every 30 min) is the only backup.
- Webhook handlers `console.log` the full provider body (customer data in logs).
- `npm audit`: 8 critical, 31 high in production dependencies. Nest 9 is out of support.
- CI (`.github/workflows/push.yml`) is the production deploy (push to `prod`); it runs no lint
  or tests before deploying. It is inert in this monorepo and must stay that way.
- One shared `ACCESS_TOKEN_SECRET` for users, bikers and admins; the `ADMIN_JWT_*` variables
  in `.env` are unused.

## Order of work (suggested)

1-5 above are small, local fixes (guards and ownership filters) and should go out together.
Then 1 again with the Moyasar API check, 7, 8, OTP throttling, the test numbers and the
Dockerfile. Each needs a backend deploy: the apps talk to the live server and there is no
staging backend yet (open decision in `docs/HANDOFF.md`).
