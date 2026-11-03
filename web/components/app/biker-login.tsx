'use client';

import { Eye, EyeOff, Loader2 } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useState, type FormEvent } from 'react';
import { AuthShell } from '@/components/app/auth-shell';
import { Field } from '@/components/app/field';
import { Button } from '@/components/ui/button';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { ApiError, authApi } from '@/lib/kleano/client';

export function BikerLogin({ t, locale, themeLabel }: { t: AppDictionary; locale: Locale; themeLabel: string }) {
  const router = useRouter();
  const [userName, setUserName] = useState('');
  const [password, setPassword] = useState('');
  const [show, setShow] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    if (busy) return;
    if (password.length < 8) {
      setError(t.biker.minPassword);
      return;
    }
    setBusy(true);
    setError(null);
    try {
      await authApi.bikerLogin(userName, password);
      router.replace(`/${locale}/biker`);
      router.refresh();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : String(err));
      setBusy(false);
    }
  };

  return (
    <AuthShell title={t.biker.title} subtitle={t.biker.subtitle} homeHref={`/${locale}`} homeLabel={t.backToSite} themeLabel={themeLabel}>
      <form onSubmit={submit} className="grid gap-5" noValidate>
        <Field
          id="userName"
          label={t.biker.userName}
          autoComplete="username"
          value={userName}
          onChange={(e) => setUserName(e.target.value)}
          autoFocus
          required
        />
        <Field
          id="password"
          label={t.biker.password}
          type={show ? 'text' : 'password'}
          autoComplete="current-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          error={error}
          required
          end={
            <button
              type="button"
              onClick={() => setShow((v) => !v)}
              aria-label={show ? t.biker.hidePassword : t.biker.showPassword}
              className="grid size-9 shrink-0 place-items-center rounded-full text-muted-foreground hover:text-foreground"
            >
              {show ? <EyeOff className="size-5" /> : <Eye className="size-5" />}
            </button>
          }
        />
        <Button type="submit" size="xl" className="mt-1 w-full" disabled={busy || !userName.trim() || !password}>
          {busy ? <Loader2 className="animate-spin" /> : null}
          {t.biker.login}
        </Button>
        <p className="text-center text-sm text-muted-foreground">{t.biker.forgot}</p>
      </form>
    </AuthShell>
  );
}
