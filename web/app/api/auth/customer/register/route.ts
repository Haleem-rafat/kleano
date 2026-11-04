import { NextResponse, type NextRequest } from 'next/server';
import { isDialCode } from '@/lib/dial-codes';
import { backendFetch } from '@/lib/kleano/backend';
import { errorResponse, langOf } from '@/lib/kleano/route-helpers';
import { deviceId } from '@/lib/kleano/session';
import { buildInternationalPhone, isPlausiblePhone } from '@/lib/phone';

/** Step 1 of sign up (POST /auth/users/register): keeps a pending user and texts a code. */
export async function POST(req: NextRequest) {
  const lang = langOf(req);
  const input = (await req.json().catch(() => ({}))) as { userName?: string; email?: string; phone?: string; dialCode?: string };
  const phone = buildInternationalPhone(input.phone ?? '', isDialCode(input.dialCode) ? input.dialCode : undefined);
  if (!input.userName || !isPlausiblePhone(phone)) {
    return NextResponse.json({ message: lang === 'ar' ? 'أدخل رقم هاتف صحيحًا.' : 'Enter a valid phone number.' }, { status: 400 });
  }
  try {
    await backendFetch('/auth/users/register', {
      method: 'POST',
      lang,
      json: { userName: input.userName, ...(input.email ? { email: input.email } : {}), phone, fcmToken: await deviceId() },
    });
    return NextResponse.json({ phone });
  } catch (error) {
    return errorResponse(error, lang);
  }
}
