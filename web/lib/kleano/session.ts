import 'server-only';
import { cookies } from 'next/headers';
import { backendFetch } from './backend';

export type Role = 'customer' | 'biker';

/**
 * One login per role, side by side: logging in as a biker never logs the customer out (and the
 * other way round). Cookies: kleano_customer_access / _refresh and kleano_biker_access / _refresh.
 */
const ACCESS = (role: Role) => `kleano_${role}_access`;
const REFRESH = (role: Role) => `kleano_${role}_refresh`;
const DEVICE = 'kleano_device';

const secure = process.env.NODE_ENV === 'production';
const base = { httpOnly: true, secure, sameSite: 'lax' as const, path: '/' };
// The backend's refresh token lives 60 days (auth.service.ts generateRefreshToken).
const SIXTY_DAYS = 60 * 60 * 24 * 60;

export type Session = { role: Role; access: string; refresh: string };

export async function getSession(role: Role): Promise<Session | null> {
  const jar = await cookies();
  const access = jar.get(ACCESS(role))?.value;
  const refresh = jar.get(REFRESH(role))?.value;
  if (!access || !refresh || isExpired(refresh)) return null;
  return { role, access, refresh };
}

export async function setSession(role: Role, access: string, refresh: string) {
  const jar = await cookies();
  jar.set(ACCESS(role), access, { ...base, maxAge: SIXTY_DAYS });
  jar.set(REFRESH(role), refresh, { ...base, maxAge: SIXTY_DAYS });
}

export async function clearSession(role: Role) {
  const jar = await cookies();
  jar.delete(ACCESS(role));
  jar.delete(REFRESH(role));
}

/**
 * The backend needs a push token at log in (fcmToken). Until web push is set up, each browser
 * gets its own "web-…" id. The backend adds it to the account's token list and later drops
 * tokens that don't work, so the phone app's notifications are not affected.
 */
export async function deviceId(): Promise<string> {
  const jar = await cookies();
  const existing = jar.get(DEVICE)?.value;
  if (existing) return existing;
  const id = `web-${crypto.randomUUID()}`;
  jar.set(DEVICE, id, { ...base, maxAge: SIXTY_DAYS * 6 });
  return id;
}

/** Same rule as the apps' AuthInterceptor: a JWT whose exp has passed (with 30 s margin). */
export function isExpired(jwt: string): boolean {
  try {
    const payload = JSON.parse(Buffer.from(jwt.split('.')[1], 'base64url').toString('utf8')) as { exp?: number };
    return !payload.exp || payload.exp * 1000 < Date.now() + 30_000;
  } catch {
    return true;
  }
}

/** POST /auth/refresh-token replies { data: { access_token, refresh_token } }. */
type Tokens = { data?: { access_token?: string; refresh_token?: string } };

/**
 * Swaps the refresh token for new tokens (POST /auth/refresh-token), like the apps do.
 * Returns the new session, 'rejected' when the backend refuses the refresh token (sign out),
 * or 'offline' when the call itself failed (keep the session, as the apps do).
 */
export async function refreshSession(session: Session): Promise<Session | 'rejected' | 'offline'> {
  if (isExpired(session.refresh)) return 'rejected';
  try {
    const res = await backendFetch<Tokens>('/auth/refresh-token', {
      method: 'POST',
      json: { refresh_token: session.refresh },
    });
    const access = res.data?.access_token;
    const refresh = res.data?.refresh_token;
    if (!access || !refresh) return 'rejected';
    await setSession(session.role, access, refresh);
    return { role: session.role, access, refresh };
  } catch (error) {
    const status = (error as { status?: number }).status;
    return status === 401 || status === 404 ? 'rejected' : 'offline';
  }
}
