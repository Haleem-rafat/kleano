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

async function request<T>(url: string, init: { method?: string; json?: unknown } = {}): Promise<T> {
  const headers: Record<string, string> = { 'x-kleano-lang': lang(), 'x-kleano-role': role() };
  if (init.json !== undefined) headers['Content-Type'] = 'application/json';
  const res = await fetch(url, {
    method: init.method ?? (init.json !== undefined ? 'POST' : 'GET'),
    headers,
    body: init.json !== undefined ? JSON.stringify(init.json) : undefined,
  });
  const data = (await res.json().catch(() => null)) as (T & { message?: unknown }) | null;
  if (!res.ok) {
    const message = typeof data?.message === 'string' ? data.message : lang() === 'ar' ? 'حدث خطأ ما.' : 'Something went wrong.';
    throw new ApiError(message, res.status);
  }
  return data as T;
}

/** Log in, log out and other calls to this site's own routes. */
export const authApi = {
  sendCustomerOtp: (phone: string) => request<{ phone: string }>('/api/auth/customer/send-otp', { json: { phone } }),
  customerLogin: (phone: string, otp: string) => request<{ userName: string | null }>('/api/auth/customer/login', { json: { phone, otp } }),
  bikerLogin: (userName: string, password: string) =>
    request<{ userName: string | null }>('/api/auth/biker/login', { json: { userName, password } }),
  logout: (who: 'customer' | 'biker') => request<{ ok: true }>('/api/auth/logout', { json: { role: who } }),
};

/** Calls to the Kleano API through the forwarding route, e.g. kleano('/orders/user/all'). */
export function kleano<T>(path: string, init: { method?: string; json?: unknown } = {}): Promise<T> {
  return request<T>(`/api/kleano${path.startsWith('/') ? path : `/${path}`}`, init);
}
