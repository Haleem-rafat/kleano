'use client';

import { Loader2 } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useEffect, useState, type FormEvent } from 'react';
import { AuthShell } from '@/components/app/auth-shell';
import { Field } from '@/components/app/field';
import { GlowButton } from '@/components/app/glow-button';
import { Button } from '@/components/ui/button';
import { InputOTP, InputOTPGroup, InputOTPSlot } from '@/components/ui/input-otp';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { ApiError, authApi } from '@/lib/kleano/client';
import { cleanPhoneInput, defaultDialCode } from '@/lib/phone';

const RESEND_AFTER = 120; // seconds, as in the app's OTP screen

/** Seconds left until the code can be resent. Only this line re-renders each second. */
function ResendTimer({ until, label, onDone }: { until: number; label: string; onDone: () => void }) {
  const [left, setLeft] = useState(() => Math.max(0, Math.ceil((until - Date.now()) / 1000)));
  useEffect(() => {
    const id = setInterval(() => {
      const next = Math.max(0, Math.ceil((until - Date.now()) / 1000));
      setLeft(next);
      if (next === 0) {
        clearInterval(id);
        onDone();
      }
    }, 1000);
    return () => clearInterval(id);
  }, [until, onDone]);
  const mm = Math.floor(left / 60);
  const ss = String(left % 60).padStart(2, '0');
  return (
    <span className="text-sm text-muted-foreground">
      {label} <span className="tabular-nums" dir="ltr">{`${mm}:${ss}`}</span>
    </span>
  );
}

export function CustomerLogin({ t, locale, themeLabel }: { t: AppDictionary; locale: Locale; themeLabel: string }) {
  const router = useRouter();
  const [step, setStep] = useState<'phone' | 'code'>('phone');
  const [input, setInput] = useState('');
  const [phone, setPhone] = useState('');
  const [code, setCode] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [resendAt, setResendAt] = useState(0);
  const [canResend, setCanResend] = useState(false);

  const sendCode = async () => {
    setBusy(true);
    setError(null);
    try {
      const res = await authApi.sendCustomerOtp(input);
      setPhone(res.phone);
      setCode('');
      setStep('code');
      setCanResend(false);
      setResendAt(Date.now() + RESEND_AFTER * 1000);
    } catch (e) {
      setError(e instanceof ApiError ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  };

  const verify = async (otp: string) => {
    if (otp.length !== 6) {
      setError(t.customer.codeLength);
      return;
    }
    setBusy(true);
    setError(null);
    try {
      await authApi.customerLogin(phone, otp);
      router.replace(`/${locale}/app`);
      router.refresh();
    } catch (e) {
      setError(e instanceof ApiError ? e.message : String(e));
      setBusy(false);
    }
  };

  const onPhoneSubmit = (e: FormEvent) => {
    e.preventDefault();
    if (!busy) void sendCode();
  };

  if (step === 'phone') {
    return (
      <AuthShell title={t.customer.title} subtitle={t.customer.subtitle} homeHref={`/${locale}`} homeLabel={t.backToSite} themeLabel={themeLabel}>
        <form onSubmit={onPhoneSubmit} className="grid gap-6" noValidate>
          <Field
            id="phone"
            label={t.customer.phone}
            type="tel"
            inputMode="tel"
            autoComplete="tel-national"
            dir="ltr"
            value={input}
            onChange={(e) => setInput(cleanPhoneInput(e.target.value))}
            error={error}
            start={
              <span className="shrink-0 font-medium text-muted-foreground" dir="ltr">
                {defaultDialCode}
              </span>
            }
            placeholder="1X XXXX XXXX"
            autoFocus
            required
          />
          <GlowButton type="submit" disabled={busy || input.length < 9}>
            {busy ? <Loader2 className="animate-spin" /> : null}
            {t.customer.continue}
          </GlowButton>
          <p className="text-center text-sm text-muted-foreground">{t.customer.noAccount}</p>
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
      <form
        onSubmit={(e) => {
          e.preventDefault();
          if (!busy) void verify(code);
        }}
        className="grid gap-6"
        noValidate
      >
        <div className="grid justify-items-center gap-2" dir="ltr">
          <InputOTP
            maxLength={6}
            value={code}
            onChange={(value) => {
              setCode(value);
              if (value.length === 6 && !busy) void verify(value);
            }}
            autoComplete="one-time-code"
            inputMode="numeric"
            autoFocus
            aria-label={t.customer.codeTitle}
          >
            <InputOTPGroup>
              {[0, 1, 2, 3, 4, 5].map((i) => (
                <InputOTPSlot key={i} index={i} className="size-12 text-lg" />
              ))}
            </InputOTPGroup>
          </InputOTP>
        </div>
        {error ? (
          <p role="alert" className="text-center text-[13px] text-destructive">
            {error}
          </p>
        ) : null}
        <GlowButton type="submit" disabled={busy || code.length !== 6}>
          {busy ? <Loader2 className="animate-spin" /> : null}
          {t.customer.verify}
        </GlowButton>
        <div className="flex flex-wrap items-center justify-between gap-2">
          <Button
            type="button"
            variant="link"
            className="px-0"
            onClick={() => {
              setStep('phone');
              setError(null);
            }}
          >
            {t.customer.changePhone}
          </Button>
          {canResend ? (
            <Button type="button" variant="link" className="px-0" disabled={busy} onClick={() => void sendCode()}>
              {t.customer.resend}
            </Button>
          ) : (
            <ResendTimer until={resendAt} label={t.customer.resendIn} onDone={() => setCanResend(true)} />
          )}
        </div>
      </form>
    </AuthShell>
  );
}
