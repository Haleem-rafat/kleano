'use client';

import { Loader2 } from 'lucide-react';
import { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';
import { InputOTP, InputOTPGroup, InputOTPSlot } from '@/components/ui/input-otp';
import type { AppDictionary } from '@/lib/app-dictionary';
import { ApiError } from '@/lib/kleano/client';

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

/** The 6-digit code step, shared by log in and sign up. */
export function OtpStep({
  t,
  onVerify,
  onResend,
  onChangePhone,
}: {
  t: AppDictionary;
  onVerify: (code: string) => Promise<void>;
  onResend: () => Promise<void>;
  onChangePhone: () => void;
}) {
  const [code, setCode] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [resendAt, setResendAt] = useState(() => Date.now() + RESEND_AFTER * 1000);
  const [canResend, setCanResend] = useState(false);

  const verify = async (otp: string) => {
    if (otp.length !== 6) {
      setError(t.customer.codeLength);
      return;
    }
    setBusy(true);
    setError(null);
    try {
      await onVerify(otp);
    } catch (e) {
      setError(e instanceof ApiError ? e.message : String(e));
      setBusy(false);
    }
  };

  const resend = async () => {
    setBusy(true);
    setError(null);
    try {
      await onResend();
      setCode('');
      setCanResend(false);
      setResendAt(Date.now() + RESEND_AFTER * 1000);
    } catch (e) {
      setError(e instanceof ApiError ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  };

  return (
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
              <InputOTPSlot key={i} index={i} className="size-11 text-lg sm:size-12" />
            ))}
          </InputOTPGroup>
        </InputOTP>
      </div>
      {error ? (
        <p role="alert" className="text-center text-sm text-destructive">
          {error}
        </p>
      ) : null}
      <Button type="submit" size="xl" className="w-full" disabled={busy || code.length !== 6}>
        {busy ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
        {t.customer.verify}
      </Button>
      <div className="flex flex-wrap items-center justify-between gap-2">
        <Button type="button" variant="link" className="px-0" onClick={onChangePhone}>
          {t.customer.changePhone}
        </Button>
        {canResend ? (
          <Button type="button" variant="link" className="px-0" disabled={busy} onClick={() => void resend()}>
            {t.customer.resend}
          </Button>
        ) : (
          <ResendTimer until={resendAt} label={t.customer.resendIn} onDone={() => setCanResend(true)} />
        )}
      </div>
    </form>
  );
}
