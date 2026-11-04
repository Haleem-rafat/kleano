'use client';

import { useQuery } from '@tanstack/react-query';
import { Failed } from '@/components/app/bits';
import { Sheet } from '@/components/app/kit';
import { Skeleton } from '@/components/ui/skeleton';
import type { AppDictionary } from '@/lib/app-dictionary';
import { kleano } from '@/lib/kleano/client';
import { localized, type LocalizedText, type Wrapped } from '@/lib/kleano/types';

/** GET /terms: { data: { content: { ar, en } } }, open to guests. A 404 means nothing is published. */
export function useTerms() {
  return useQuery({
    queryKey: ['terms'],
    retry: false,
    queryFn: () =>
      kleano<Wrapped<{ content?: LocalizedText | string } | null>>('/terms')
        .then((r) => r.data?.content ?? null)
        .catch((e: { status?: number }) => {
          if (e.status === 404) return null;
          throw e;
        }),
  });
}

export function TermsBody({ t, locale }: { t: AppDictionary; locale?: string }) {
  const terms = useTerms();
  const lang = locale ?? (typeof document !== 'undefined' ? document.documentElement.lang : 'ar');
  if (terms.isPending) {
    return (
      <div role="status" aria-label={t.common.loading} className="grid gap-3">
        {[90, 100, 75, 95, 60].map((w) => (
          <Skeleton key={w} className="h-4" style={{ width: `${w}%` }} />
        ))}
      </div>
    );
  }
  if (terms.isError) return <Failed message={terms.error.message} onRetry={() => terms.refetch()} t={t} />;
  const text = typeof terms.data === 'string' ? terms.data : localized(terms.data ?? undefined, lang);
  if (!text) return <p className="py-8 text-center text-muted-foreground">{t.terms.empty}</p>;
  return <div className="whitespace-pre-line text-[15px] leading-relaxed">{text}</div>;
}

export function TermsSheet({ t, open, onOpenChange }: { t: AppDictionary; open: boolean; onOpenChange: (open: boolean) => void }) {
  return (
    <Sheet open={open} onOpenChange={onOpenChange} title={t.terms.title} closeLabel={t.terms.close} wide>
      {open ? <TermsBody t={t} /> : null}
    </Sheet>
  );
}
