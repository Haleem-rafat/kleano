import { NextResponse, type NextRequest } from 'next/server';
import { backendFetch } from '@/lib/kleano/backend';
import { errorResponse, langOf } from '@/lib/kleano/route-helpers';

/** Sends the sign-up code again (POST /auth/pending-users/send-register-otp). */
export async function POST(req: NextRequest) {
  const lang = langOf(req);
  const { phone } = (await req.json().catch(() => ({}))) as { phone?: string };
  if (!phone) return NextResponse.json({ message: lang === 'ar' ? 'أدخل رقم الهاتف.' : 'Enter the phone number.' }, { status: 400 });
  try {
    await backendFetch('/auth/pending-users/send-register-otp', { method: 'POST', lang, json: { phone } });
    return NextResponse.json({ phone });
  } catch (error) {
    return errorResponse(error, lang);
  }
}
