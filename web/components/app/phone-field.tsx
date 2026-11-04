'use client';

import { ChevronDown } from 'lucide-react';
import { useMemo, useState, type ComponentProps } from 'react';
import { Field } from '@/components/app/field';
import { PickerSheet } from '@/components/app/kit';
import type { AppDictionary } from '@/lib/app-dictionary';
import { dialOptions } from '@/lib/dial-codes';
import type { Locale } from '@/lib/i18n';

/** Phone input with the country code button, like the app's sign up and log in screens. */
export function PhoneField({
  t,
  locale,
  dialCode,
  onDialCode,
  ...props
}: ComponentProps<typeof Field> & { t: AppDictionary; locale: Locale; dialCode: string; onDialCode: (code: string) => void }) {
  const [open, setOpen] = useState(false);
  const options = useMemo(() => dialOptions(locale), [locale]);
  return (
    <>
      <Field
        type="tel"
        inputMode="tel"
        autoComplete="tel-national"
        dir="ltr"
        className="ps-22"
        placeholder="1X XXXX XXXX"
        start={
          <button
            type="button"
            onClick={() => setOpen(true)}
            aria-label={t.signup.country}
            className="pointer-events-auto -ms-2 inline-flex h-9 items-center gap-1 rounded-lg px-2 font-medium text-foreground transition hover:bg-background/60"
            dir="ltr"
          >
            {dialCode}
            <ChevronDown className="size-3.5 text-muted-foreground" aria-hidden="true" />
          </button>
        }
        {...props}
      />
      <PickerSheet
        open={open}
        onOpenChange={setOpen}
        title={t.signup.country}
        options={options}
        value={dialCode}
        onPick={(code) => {
          onDialCode(code);
          setOpen(false);
        }}
        searchLabel={t.signup.searchCountry}
        emptyText={t.signup.noResults}
        closeLabel={t.terms.close}
      />
    </>
  );
}
