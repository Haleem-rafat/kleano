import 'server-only';
import { cookies } from 'next/headers';
import { backendFetch } from './backend';

export type Role = 'customer' | 'biker';

const ACCESS = 'kleano_access';
const REFRESH = 'kleano_refresh';
const ROLE = 'kleano_role';
const DEVICE = 'kleano_device';

const secure = process.env.NODE_ENV === 'production';
const base = { httpOnly: true, secure, sameSite: 'lax' as const, path: '/' };
const MONTH = 60 * 60 * 24 * 30;

export type Session = { role: Role; access: string; refresh: string };

export async function getSession(): Promise<Session | null> {
  const jar = await cookies();
  const role = jar.get(ROLE)?.value;
  const access = jar.get(ACCESS)?.value;
  const refresh = jar.get(REFRESH)?.value;
  if ((role !== 'customer' && role !== 'biker') || !access || !refresh) return null;
  return { role, access, refresh };
}

export async function setSession(role: Role, access: string, refresh: string) {
  const jar = await cookies();
  jar.set(ROLE, role, { ...base, maxAge: MONTH });
  jar.set(ACCESS, access, { ...base, maxAge: MONTH });
  jar.set(REFRESH, refresh, { ...base, maxAge: MONTH });
}

export async function clearSession() {
  const jar = await cookies();
  for (const name of [ROLE, ACCESS, REFRESH]) jar.delete(name);
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
  jar.set(DEVICE, id, { ...base, maxAge: MONTH * 12 });
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

type Tokens = { data?: { accessToken?: string; refreshToken?: string } };

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
    const access = res.data?.accessToken;
    const refresh = res.data?.refreshToken;
    if (!access || !refresh) return 'rejected';
    await setSession(session.role, access, refresh);
    return { role: session.role, access, refresh };
  } catch (error) {
    const status = (error as { status?: number }).status;
    return status === 401 || status === 403 || status === 404 ? 'rejected' : 'offline';
  }
}
