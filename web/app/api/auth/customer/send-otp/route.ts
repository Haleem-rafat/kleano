import { NextResponse, type NextRequest } from 'next/server';
import { backendFetch } from '@/lib/kleano/backend';
import { errorResponse, langOf } from '@/lib/kleano/route-helpers';
import { isDialCode } from '@/lib/dial-codes';
import { buildInternationalPhone, isPlausiblePhone } from '@/lib/phone';

/** Step 1 of customer log in: the backend texts a code to the phone (POST /auth/users/send-otp). */
export async function POST(req: NextRequest) {
  const lang = langOf(req);
  const { phone: input, dialCode } = (await req.json().catch(() => ({}))) as { phone?: string; dialCode?: string };
  const phone = buildInternationalPhone(input ?? '', isDialCode(dialCode) ? dialCode : undefined);
  if (!isPlausiblePhone(phone)) {
    return NextResponse.json(
      { message: lang === 'ar' ? 'أدخل رقم هاتف صحيحًا.' : 'Enter a valid phone number.' },
      { status: 400 },
    );
  }
  try {
    await backendFetch('/auth/users/send-otp', { method: 'POST', lang, json: { phone } });
    return NextResponse.json({ phone });
  } catch (error) {
    return errorResponse(error, lang);
  }
}
