import { NextResponse, type NextRequest } from 'next/server';
import { backendFetch } from '@/lib/kleano/backend';
import { langOf } from '@/lib/kleano/route-helpers';
import { clearSession, deviceId, getSession } from '@/lib/kleano/session';

/** Logs out on the backend (removes this browser's token) and clears the cookies either way. */
export async function POST(req: NextRequest) {
  const session = await getSession();
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
  await clearSession();
  return NextResponse.json({ ok: true });
}
