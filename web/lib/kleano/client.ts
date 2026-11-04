/**
 * Browser-side calls. Everything goes through this site's own server (/api/...), which holds
 * the tokens in httpOnly cookies; the page never sees them.
 */

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
  ) {
    super(message);
  }
}

function lang(): 'ar' | 'en' {
  return typeof document !== 'undefined' && document.documentElement.lang === 'en' ? 'en' : 'ar';
}

/** The biker web app lives under /[locale]/biker; everything else is the customer app. */
function role(): 'customer' | 'biker' {
  return typeof window !== 'undefined' && /^\/(ar|en)\/biker(\/|$)/.test(window.location.pathname) ? 'biker' : 'customer';
}

type LocalizedMessage = { ar?: string; en?: string };

/**
 * Backend errors come as { success, message: { ar, en } }, { message: string | string[] } or
 * { ar, en } (HttpException with a plain object). Same reading as the app's ErrorModel.
 */
function messageFrom(data: unknown): string | undefined {
  if (!data || typeof data !== 'object') return undefined;
  const body = data as { message?: unknown } & LocalizedMessage;
  const message = body.message ?? (body.ar || body.en ? body : undefined);
  if (typeof message === 'string') return message;
  if (Array.isArray(message)) return message.join('\n');
  if (message && typeof message === 'object') {
    const m = message as LocalizedMessage & { message?: unknown };
    // Some services throw { success, message: { ar, en } } inside the exception's own message.
    if (m.message) return messageFrom(m);
    return (lang() === 'ar' ? m.ar : m.en) ?? m.en ?? m.ar;
  }
  return undefined;
}

export const SESSION_EXPIRED_EVENT = 'kleano:session-expired';

export type KleanoRequest = { method?: string; json?: unknown; form?: FormData };

async function request<T>(url: string, init: KleanoRequest = {}): Promise<T> {
  const headers: Record<string, string> = { 'x-kleano-lang': lang(), 'x-kleano-role': role() };
  if (init.json !== undefined) headers['Content-Type'] = 'application/json';
  // For multipart the browser writes Content-Type itself, with the boundary.
  const hasBody = init.json !== undefined || init.form !== undefined;
  let res: Response;
  try {
    res = await fetch(url, {
      method: init.method ?? (hasBody ? 'POST' : 'GET'),
      headers,
      body: init.form ?? (init.json !== undefined ? JSON.stringify(init.json) : undefined),
    });
  } catch {
    throw new ApiError(lang() === 'ar' ? 'تعذر الاتصال. تحقق من الإنترنت وحاول مرة أخرى.' : "Couldn't connect. Check your internet and try again.", 0);
  }
  const data = (await res.json().catch(() => null)) as T | null;
  if (!res.ok) {
    // The forwarding route answers 401 only after the backend refused the refresh token.
    if (res.status === 401 && url.startsWith('/api/kleano') && typeof window !== 'undefined') {
      window.dispatchEvent(new Event(SESSION_EXPIRED_EVENT));
    }
    throw new ApiError(messageFrom(data) ?? (lang() === 'ar' ? 'حدث خطأ ما.' : 'Something went wrong.'), res.status);
  }
  return data as T;
}

/** Log in, sign up, log out and other calls to this site's own routes. */
export const authApi = {
  sendCustomerOtp: (phone: string, dialCode?: string) => request<{ phone: string }>('/api/auth/customer/send-otp', { json: { phone, dialCode } }),
  customerLogin: (phone: string, otp: string) => request<{ userName: string | null }>('/api/auth/customer/login', { json: { phone, otp } }),
  /** Step 1 of sign up: the backend keeps a pending user and texts a code. */
  customerRegister: (input: { userName: string; email?: string; phone: string; dialCode?: string }) =>
    request<{ phone: string }>('/api/auth/customer/register', { json: input }),
  customerVerifyRegister: (phone: string, otp: string) => request<{ userName: string | null }>('/api/auth/customer/verify-register', { json: { phone, otp } }),
  customerResendRegister: (phone: string) => request<{ phone: string }>('/api/auth/customer/resend-register', { json: { phone } }),
  bikerLogin: (userName: string, password: string) =>
    request<{ userName: string | null }>('/api/auth/biker/login', { json: { userName, password } }),
  logout: (who: 'customer' | 'biker') => request<{ ok: true }>('/api/auth/logout', { json: { role: who } }),
  /** Ends the customer session after the account was deleted; the backend has nothing left to log out. */
  clearSession: () => request<{ ok: true }>('/api/auth/logout', { json: { role: 'customer', localOnly: true } }),
};

/** Calls to the Kleano API through the forwarding route, e.g. kleano('/orders/user/all'). */
export function kleano<T>(path: string, init: KleanoRequest = {}): Promise<T> {
  return request<T>(`/api/kleano${path.startsWith('/') ? path : `/${path}`}`, init);
}
