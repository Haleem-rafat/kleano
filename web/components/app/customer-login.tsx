'use client';

import { Loader2 } from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useState, type FormEvent } from 'react';
import { AuthShell } from '@/components/app/auth-shell';
import { OtpStep } from '@/components/app/otp-step';
import { PhoneField } from '@/components/app/phone-field';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { firstScreenAfterAuth } from '@/lib/kleano/after-auth';
import { ApiError, authApi } from '@/lib/kleano/client';
import { cleanPhoneInput, defaultDialCode } from '@/lib/phone';

export function CustomerLogin({ t, locale, themeLabel }: { t: AppDictionary; locale: Locale; themeLabel: string }) {
  const router = useRouter();
  const [step, setStep] = useState<'phone' | 'code'>('phone');
  const [input, setInput] = useState('');
  const [dialCode, setDialCode] = useState(defaultDialCode);
  const [phone, setPhone] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const sendCode = async (e: FormEvent) => {
    e.preventDefault();
    if (busy) return;
    setBusy(true);
    setError(null);
    try {
      const res = await authApi.sendCustomerOtp(input, dialCode);
      setPhone(res.phone);
      setStep('code');
    } catch (err) {
      setError(err instanceof ApiError ? err.message : String(err));
    } finally {
      setBusy(false);
    }
  };

  if (step === 'phone') {
    return (
      <AuthShell title={t.customer.title} subtitle={t.customer.subtitle} homeHref={`/${locale}`} homeLabel={t.backToSite} themeLabel={themeLabel}>
        <form onSubmit={sendCode} className="grid gap-6" noValidate>
          <PhoneField
            t={t}
            locale={locale}
            dialCode={dialCode}
            onDialCode={setDialCode}
            id="phone"
            label={t.customer.phone}
            value={input}
            onChange={(e) => setInput(cleanPhoneInput(e.target.value))}
            error={error}
            autoFocus
            required
          />
          <Button type="submit" size="xl" className="w-full" disabled={busy || input.length < 9}>
            {busy ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
            {t.customer.continue}
          </Button>
          <p className="text-center text-sm text-muted-foreground">
            {t.signup.noAccount}{' '}
            <Link href={`/${locale}/app/signup`} className="font-semibold text-primary hover:underline">
              {t.signup.signUp}
            </Link>
          </p>
        </form>
      </AuthShell>
    );
  }

  return (
    <AuthShell
      title={t.customer.codeTitle}
      subtitle={
        <>
          {t.customer.codeSubtitle}{' '}
          <span dir="ltr" className="font-semibold">
            {phone}
          </span>
        </>
      }
      homeHref={`/${locale}`}
      homeLabel={t.backToSite}
      themeLabel={themeLabel}
    >
      <OtpStep
        t={t}
        onVerify={async (code) => {
          await authApi.customerLogin(phone, code);
          router.replace(await firstScreenAfterAuth(locale));
          router.refresh();
        }}
        onResend={async () => {
          await authApi.sendCustomerOtp(phone);
        }}
        onChangePhone={() => {
          setStep('phone');
          setError(null);
        }}
      />
    </AuthShell>
  );
}
