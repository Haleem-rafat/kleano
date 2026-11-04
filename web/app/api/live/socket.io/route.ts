import { NextResponse, type NextRequest } from 'next/server';
import { backendUrl } from '@/lib/kleano/backend';
import { clearSession, getSession, isExpired, refreshSession } from '@/lib/kleano/session';

/**
 * Same-origin door to the backend's Socket.IO, polling transport only, for whichever app asks (?role=biker).
 * It adds the Authorization header the gateway reads, so page JavaScript never holds the token.
 * It forwards nothing except /socket.io/ with the query Socket.IO itself sends.
 */

// The API lives at <origin>/api; Socket.IO at <origin>/socket.io (app_config.dart socketUrl).
const socketOrigin = new URL(backendUrl).origin;

async function forward(req: NextRequest) {
  const query = req.nextUrl.searchParams;
  if (query.get('transport') !== 'polling' || !query.get('EIO')) {
    return NextResponse.json({ message: 'Not available' }, { status: 404 });
  }

  const role = query.get('role') === 'biker' ? 'biker' : 'customer';
  let session = await getSession(role);
  if (!session) return NextResponse.json({ message: 'Session expired' }, { status: 401 });
  // Only the first request of a connection is checked by the backend, so that's where it must be fresh.
  if (!query.get('sid') && isExpired(session.access)) {
    const refreshed = await refreshSession(session);
    if (refreshed === 'rejected') {
      await clearSession(role);
      return NextResponse.json({ message: 'Session expired' }, { status: 401 });
    }
    if (refreshed !== 'offline') session = refreshed;
  }

  const headers = new Headers({ Authorization: `Bearer ${session.access}` });
  const contentType = req.headers.get('content-type');
  if (contentType) headers.set('Content-Type', contentType);
  const res = await fetch(`${socketOrigin}/socket.io/${req.nextUrl.search}`, {
    method: req.method,
    headers,
    body: req.method === 'POST' ? await req.arrayBuffer() : undefined,
    cache: 'no-store',
    // A long poll stops when the page leaves.
    signal: req.signal,
  }).catch(() => null);
  if (!res) return NextResponse.json({ message: 'Unavailable' }, { status: 502 });

  return new NextResponse(res.body, {
    status: res.status,
    headers: { 'Content-Type': res.headers.get('content-type') ?? 'text/plain; charset=UTF-8', 'Cache-Control': 'no-store' },
  });
}

export const GET = forward;
export const POST = forward;
