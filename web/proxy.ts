import { NextResponse, type NextRequest } from 'next/server';
import { isLocale, localeFromHeader } from '@/lib/i18n';

/** Sends paths without a language (like "/") to /ar or /en, from the browser's language. */
export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const first = pathname.split('/')[1] ?? '';
  if (isLocale(first)) return NextResponse.next();

  const locale = localeFromHeader(request.headers.get('accept-language'));
  const url = request.nextUrl.clone();
  url.pathname = `/${locale}${pathname === '/' ? '' : pathname}`;
  return NextResponse.redirect(url);
}

export const config = {
  // Skip Next.js internals, files with an extension, and the metadata routes.
  matcher: ['/((?!_next|api|.*\\..*|sitemap.xml|robots.txt).*)'],
};
