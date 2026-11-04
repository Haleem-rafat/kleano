'use client';

import { zodResolver } from '@hookform/resolvers/zod';
import { Loader2 } from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { AuthShell } from '@/components/app/auth-shell';
import { TermsSheet } from '@/components/app/customer/terms';
import { Field } from '@/components/app/field';
import { OtpStep } from '@/components/app/otp-step';
import { PhoneField } from '@/components/app/phone-field';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { firstScreenAfterAuth } from '@/lib/kleano/after-auth';
import { ApiError, authApi } from '@/lib/kleano/client';
import { cleanPhoneInput, defaultDialCode } from '@/lib/phone';
import { signupSchema, type SignupForm } from '@/lib/validation';

/** Sign up, then the register code: same fields, rules and calls as the app's SignUpScreen. */
export function CustomerSignup({ t, locale, themeLabel }: { t: AppDictionary; locale: Locale; themeLabel: string }) {
  const router = useRouter();
  const [phone, setPhone] = useState<string | null>(null);
  const [dialCode, setDialCode] = useState(defaultDialCode);
  const [termsOpen, setTermsOpen] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const schema = useMemo(() => signupSchema(t), [t]);
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<SignupForm>({ resolver: zodResolver(schema), defaultValues: { userName: '', email: '', phone: '', accepted: false } });

  const submit = handleSubmit(async (values) => {
    setFormError(null);
    try {
      const res = await authApi.customerRegister({
        userName: values.userName.trim(),
        email: values.email?.trim() || undefined,
        phone: cleanPhoneInput(values.phone),
        dialCode,
      });
      setPhone(res.phone);
    } catch (e) {
      setFormError(e instanceof ApiError ? e.message : String(e));
    }
  });

  if (phone) {
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
            await authApi.customerVerifyRegister(phone, code);
            router.replace(await firstScreenAfterAuth(locale));
            router.refresh();
          }}
          onResend={async () => {
            await authApi.customerResendRegister(phone);
          }}
          onChangePhone={() => setPhone(null)}
        />
      </AuthShell>
    );
  }

  return (
    <AuthShell title={t.signup.title} subtitle={t.signup.subtitle} homeHref={`/${locale}`} homeLabel={t.backToSite} themeLabel={themeLabel}>
      <form onSubmit={submit} className="grid gap-5" noValidate>
        <Field id="userName" label={t.signup.name} autoComplete="name" autoFocus error={errors.userName?.message} {...register('userName')} />
        <Field id="email" label={t.signup.email} type="email" inputMode="email" autoComplete="email" placeholder={t.signup.emailHint} dir="ltr" error={errors.email?.message} {...register('email')} />
        <PhoneField t={t} locale={locale} dialCode={dialCode} onDialCode={setDialCode} id="phone" label={t.customer.phone} error={errors.phone?.message} {...register('phone')} />
        <div className="grid gap-1">
          <label className="flex cursor-pointer items-center gap-3 text-sm">
            <input type="checkbox" className="size-5 shrink-0 accent-[var(--primary)]" aria-invalid={Boolean(errors.accepted)} {...register('accepted')} />
            <span>{t.signup.acceptTerms}</span>
          </label>
          {errors.accepted?.message ? (
            <p role="alert" className="text-sm text-destructive">
              {errors.accepted.message}
            </p>
          ) : null}
          <Button type="button" variant="link" className="h-auto w-fit justify-start px-0 py-1" onClick={() => setTermsOpen(true)}>
            {t.signup.readTerms}
          </Button>
        </div>
        {formError ? (
          <p role="alert" className="text-sm text-destructive">
            {formError}
          </p>
        ) : null}
        <Button type="submit" size="xl" className="w-full" disabled={isSubmitting}>
          {isSubmitting ? <Loader2 className="animate-spin" aria-hidden="true" /> : null}
          {t.signup.signUp}
        </Button>
        <p className="text-center text-sm text-muted-foreground">
          {t.signup.haveAccount}{' '}
          <Link href={`/${locale}/app/login`} className="font-semibold text-primary hover:underline">
            {t.signup.login}
          </Link>
        </p>
      </form>
      <TermsSheet t={t} open={termsOpen} onOpenChange={setTermsOpen} />
    </AuthShell>
  );
}
