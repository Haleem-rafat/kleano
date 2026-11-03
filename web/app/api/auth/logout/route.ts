import { NextResponse, type NextRequest } from 'next/server';
import { backendFetch } from '@/lib/kleano/backend';
import { langOf } from '@/lib/kleano/route-helpers';
import { clearSession, deviceId, getSession, type Role } from '@/lib/kleano/session';

/** Logs one role out on the backend (removes this browser's token) and clears that role's cookies. */
export async function POST(req: NextRequest) {
  const { role: asked } = (await req.json().catch(() => ({}))) as { role?: string };
  const role: Role = asked === 'biker' ? 'biker' : 'customer';
  const session = await getSession(role);
  if (session) {
    const path = session.role === 'biker' ? '/auth/bikers/logout' : '/auth/users/logout';
    try {
      await backendFetch(path, {
        method: 'POST',
        token: session.access,
        lang: langOf(req),
        json: { fcmToken: await deviceId() },
      });
    } catch {
      // Still log out locally if the backend can't be reached or the token already expired.
    }
  }
  await clearSession(role);
  return NextResponse.json({ ok: true });
}
