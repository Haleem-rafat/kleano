import { NextResponse, type NextRequest } from 'next/server';
import { backendFetch } from '@/lib/kleano/backend';
import { errorResponse, langOf } from '@/lib/kleano/route-helpers';
import { deviceId, setSession } from '@/lib/kleano/session';
import { toAsciiDigits } from '@/lib/phone';

type LoginReply = { data?: { accessToken?: string; refreshToken?: string; userName?: string } };

/** Step 2 of customer log in: phone + texted code (POST /auth/users/login). Tokens go into httpOnly cookies. */
export async function POST(req: NextRequest) {
  const lang = langOf(req);
  const { phone, otp } = (await req.json().catch(() => ({}))) as { phone?: string; otp?: string };
  const code = toAsciiDigits(otp ?? '').replace(/\D/g, '');
  if (!phone || !code) {
    return NextResponse.json({ message: lang === 'ar' ? 'أدخل الرمز.' : 'Enter the code.' }, { status: 400 });
  }
  try {
    const res = await backendFetch<LoginReply>('/auth/users/login', {
      method: 'POST',
      lang,
      json: { phone, otp: code, fcmToken: await deviceId() },
    });
    const access = res.data?.accessToken;
    const refresh = res.data?.refreshToken;
    if (!access || !refresh) throw new Error('No tokens in login reply');
    await setSession('customer', access, refresh);
    return NextResponse.json({ userName: res.data?.userName ?? null });
  } catch (error) {
    return errorResponse(error, lang);
  }
}
