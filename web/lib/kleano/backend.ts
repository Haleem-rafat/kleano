import 'server-only';

/** The live Kleano API, the same one the apps use (customer-app/lib/api/app_config.dart). */
export const backendUrl = (process.env.KLEANO_API_URL ?? 'https://kleano-backend.onrender.com/api').replace(/\/$/, '');

/** The backend sends messages in both languages: { ar, en }. */
export type BackendMessage = { ar?: string; en?: string } | string | string[] | undefined;

export class BackendError extends Error {
  constructor(
    public status: number,
    public body: unknown,
  ) {
    super(`Kleano API ${status}`);
  }
}

type BackendInit = {
  method?: string;
  token?: string;
  lang?: string;
  body?: BodyInit | null;
  json?: unknown;
  contentType?: string | null;
};

/** One call to the backend. Returns the parsed JSON, or throws BackendError with the backend's reply. */
export async function backendFetch<T = unknown>(path: string, init: BackendInit = {}): Promise<T> {
  const headers = new Headers();
  if (init.token) headers.set('Authorization', `Bearer ${init.token}`);
  if (init.lang) headers.set('Accept-Language', init.lang);
  let body = init.body ?? null;
  if (init.json !== undefined) {
    headers.set('Content-Type', 'application/json');
    body = JSON.stringify(init.json);
  } else if (init.contentType) {
    headers.set('Content-Type', init.contentType);
  }

  const res = await fetch(`${backendUrl}${path.startsWith('/') ? path : `/${path}`}`, {
    method: init.method ?? 'GET',
    headers,
    body,
    cache: 'no-store',
  });

  const text = await res.text();
  let data: unknown = text;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    // Non-JSON reply: keep the text.
  }
  if (!res.ok) throw new BackendError(res.status, data);
  return data as T;
}

/** Picks the message in the visitor's language from a backend error body. */
export function messageOf(body: unknown, lang: string): string | undefined {
  if (!body || typeof body !== 'object') return undefined;
  const message = (body as { message?: BackendMessage }).message;
  if (!message) return undefined;
  if (typeof message === 'string') return message;
  if (Array.isArray(message)) return message.join('\n');
  return (lang === 'ar' ? message.ar : message.en) ?? message.en ?? message.ar;
}
