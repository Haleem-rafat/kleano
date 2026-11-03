import { NextResponse, type NextRequest } from 'next/server';
import { backendFetch } from '@/lib/kleano/backend';
import { errorResponse, langOf } from '@/lib/kleano/route-helpers';
import { deviceId, setSession } from '@/lib/kleano/session';

type LoginReply = { data?: { accessToken?: string; refreshToken?: string; userName?: string } };

/** Biker log in: user name + password (POST /auth/bikers/login), as in biker-app AuthRepo.bikerLogin. */
export async function POST(req: NextRequest) {
  const lang = langOf(req);
  const { userName, password } = (await req.json().catch(() => ({}))) as { userName?: string; password?: string };
  if (!userName?.trim() || !password) {
    return NextResponse.json(
      { message: lang === 'ar' ? 'أدخل اسم المستخدم وكلمة المرور.' : 'Enter your user name and password.' },
      { status: 400 },
    );
  }
  try {
    const res = await backendFetch<LoginReply>('/auth/bikers/login', {
      method: 'POST',
      lang,
      json: { userName: userName.trim(), password, fcmToken: await deviceId() },
    });
    const access = res.data?.accessToken;
    const refresh = res.data?.refreshToken;
    if (!access || !refresh) throw new Error('No tokens in login reply');
    await setSession('biker', access, refresh);
    return NextResponse.json({ userName: res.data?.userName ?? null });
  } catch (error) {
    return errorResponse(error, lang);
  }
}
