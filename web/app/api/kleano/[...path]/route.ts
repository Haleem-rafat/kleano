import { NextResponse, type NextRequest } from 'next/server';
import { backendUrl } from '@/lib/kleano/backend';
import { langOf } from '@/lib/kleano/route-helpers';
import { clearSession, getSession, isExpired, refreshSession, type Role, type Session } from '@/lib/kleano/session';

/**
 * Forwards the web app's calls to the Kleano API with the signed-in token, the same way the
 * apps' AuthInterceptor does: refresh an expired token first, and on 403 refresh once and retry.
 * Guests (no session) are forwarded without a token, so guest browsing works like in the app.
 */

// Admin routes belong to the dashboard, never to the customer or biker web app.
const blocked = /(^|\/)(admins?|users-admin|qoyod)(\/|$)|\/admin\//;

async function forward(req: NextRequest, path: string[]) {
  const target = path.join('/');
  if (blocked.test(`/${target}`)) {
    return NextResponse.json({ message: 'Not available' }, { status: 404 });
  }

  const lang = langOf(req);
  // Which app is calling: the customer and biker logins are kept apart.
  const role: Role = req.headers.get('x-kleano-role') === 'biker' ? 'biker' : 'customer';
  const url = `${backendUrl}/${target}${req.nextUrl.search}`;
  const hasBody = req.method !== 'GET' && req.method !== 'HEAD';
  // Read the body once so the request can be retried after a token refresh.
  const body = hasBody ? await req.arrayBuffer() : undefined;
  const contentType = req.headers.get('content-type');

  let session: Session | null = await getSession(role);
  if (session && isExpired(session.access)) {
    const refreshed = await refreshSession(session);
    if (refreshed === 'rejected') {
      await clearSession(role);
      return NextResponse.json({ message: 'Session expired' }, { status: 401 });
    }
    if (refreshed !== 'offline') session = refreshed;
  }

  const send = (token?: string) => {
    const headers = new Headers({ 'Accept-Language': lang });
    if (contentType) headers.set('Content-Type', contentType);
    if (token) headers.set('Authorization', `Bearer ${token}`);
    return fetch(url, { method: req.method, headers, body, cache: 'no-store' });
  };

  let res = await send(session?.access);

  // The backend answers 403 (not 401) for missing or expired credentials.
  if (res.status === 403 && session) {
    const refreshed = await refreshSession(session);
    if (refreshed === 'rejected') {
      await clearSession(role);
      return NextResponse.json({ message: 'Session expired' }, { status: 401 });
    }
    if (refreshed !== 'offline') res = await send(refreshed.access);
  }

  return new NextResponse(res.body, {
    status: res.status,
    headers: { 'Content-Type': res.headers.get('content-type') ?? 'application/json' },
  });
}

type Ctx = { params: Promise<{ path: string[] }> };

export async function GET(req: NextRequest, { params }: Ctx) {
  return forward(req, (await params).path);
}
export async function POST(req: NextRequest, { params }: Ctx) {
  return forward(req, (await params).path);
}
export async function PUT(req: NextRequest, { params }: Ctx) {
  return forward(req, (await params).path);
}
export async function PATCH(req: NextRequest, { params }: Ctx) {
  return forward(req, (await params).path);
}
export async function DELETE(req: NextRequest, { params }: Ctx) {
  return forward(req, (await params).path);
}
