import { NextResponse, type NextRequest } from 'next/server';
import { backendFetch } from '@/lib/kleano/backend';
import { errorResponse, langOf } from '@/lib/kleano/route-helpers';
import { setSession } from '@/lib/kleano/session';
import { toAsciiDigits } from '@/lib/phone';

type Reply = { data?: { access_token?: string; refresh_token?: string; userName?: string } };

/** Step 2 of sign up (POST /auth/pending-users/verify-register-otp). Tokens go into httpOnly cookies. */
export async function POST(req: NextRequest) {
  const lang = langOf(req);
  const { phone, otp } = (await req.json().catch(() => ({}))) as { phone?: string; otp?: string };
  const code = toAsciiDigits(otp ?? '').replace(/\D/g, '');
  if (!phone || !code) {
    return NextResponse.json({ message: lang === 'ar' ? 'أدخل الرمز.' : 'Enter the code.' }, { status: 400 });
  }
  try {
    const res = await backendFetch<Reply>('/auth/pending-users/verify-register-otp', { method: 'POST', lang, json: { phone, otp: code } });
    const access = res.data?.access_token;
    const refresh = res.data?.refresh_token;
    if (!access || !refresh) throw new Error('No tokens in verify reply');
    await setSession('customer', access, refresh);
    return NextResponse.json({ userName: res.data?.userName ?? null });
  } catch (error) {
    return errorResponse(error, lang);
  }
}
