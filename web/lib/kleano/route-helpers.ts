import 'server-only';
import { NextResponse, type NextRequest } from 'next/server';
import { BackendError, messageOf } from './backend';

/** The page's language, sent by the web client so backend messages come back in it. */
export function langOf(req: NextRequest): 'ar' | 'en' {
  return req.headers.get('x-kleano-lang') === 'en' ? 'en' : 'ar';
}

/** Turns any failure into { message } JSON with the backend's status and its message in the page language. */
export function errorResponse(error: unknown, lang: 'ar' | 'en') {
  if (error instanceof BackendError) {
    return NextResponse.json(
      { message: messageOf(error.body, lang) ?? fallback(lang) },
      { status: error.status >= 400 ? error.status : 502 },
    );
  }
  return NextResponse.json({ message: offline(lang) }, { status: 502 });
}

const fallback = (lang: 'ar' | 'en') => (lang === 'ar' ? 'حدث خطأ ما. حاول مرة أخرى.' : 'Something went wrong. Try again.');
const offline = (lang: 'ar' | 'en') =>
  lang === 'ar' ? 'تعذر الوصول إلى خادم كلينو. تحقق من الاتصال وحاول مرة أخرى.' : "Couldn't reach Kleano. Check your connection and try again.";
