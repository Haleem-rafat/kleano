# Kleano: open issues (internal, not for the client)

Updated 2026-10-31. The items that had a clear fix are done; see the git history of each app.

## Needs your decision
- **Biker Accept or decline:** the biker app has no reachable Accept step, yet onboarding says "Accept requests". How should orders reach a biker?
- **Bikers cancelling an order:** there is no button. Should they be able to?
- **Top Up wording:** the dashboard says "points", the action is "add-balance", and User Details shows wallet balance. Which is it?
- **Market:** phone default is Egypt, prices are SAR, services request "saudi arabia", and search has a "FORCED COUNTRY FOR TESTING" line set to Egypt.
- **Changing a phone number:** the dead screen was removed. It needs a backend verification step to return.
- **Biker order history offline:** still hidden while offline. Should it stay hidden?
- **Delete abilities in the dashboard:** no delete for users, bikers, services, plans, add-ons, promo codes, segments or banners; cities can't be removed or created.

## Needs a real payment test
- **Points with Apple Pay:** the charge appears to use the server's total after points, but one local total ignores points. Test before changing.
- **Plan via Apple Pay:** any payment response counts as success, with no follow-up server step.

## Needs testing
- Dashboard forms with test records, including the Weekend Commission fix.
- Tapping a real push notification, which needs a paid Apple account on iPhone.
