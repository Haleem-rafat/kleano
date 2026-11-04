'use client';

import { FileText, Globe, Mail, MessageCircle, Phone, Share2 } from 'lucide-react';
import { useState } from 'react';
import { Failed, PageTitle, SectionTitle } from '@/components/app/bits';
import { TermsSheet } from '@/components/app/customer/terms';
import { Row, RowGroup, RowsSkeleton } from '@/components/app/kit';
import type { AppDictionary } from '@/lib/app-dictionary';
import type { Locale } from '@/lib/i18n';
import { useContactInfo } from '@/lib/kleano/queries';

const external = { target: '_blank', rel: 'noreferrer' } as const;

function LinkRow({ href, icon, title, subtitle, blank }: { href: string; icon: React.ReactNode; title: React.ReactNode; subtitle?: React.ReactNode; blank?: boolean }) {
  return (
    <a href={href} {...(blank ? external : {})} className="block transition hover:bg-muted/60">
      <Row icon={icon} title={title} subtitle={subtitle} />
    </a>
  );
}

/** The app's About us: terms, then GET /contact-info, showing only what the backend has. */
export function CustomerAbout({ t }: { t: AppDictionary; locale: Locale }) {
  const contact = useContactInfo();
  const [terms, setTerms] = useState(false);
  const info = contact.data;
  const social = info
    ? ([
        ['Facebook', info.facebookLink],
        ['Instagram', info.instagramLink],
        ['X', info.twitterLink],
        ['YouTube', info.youtubeLink],
        ['LinkedIn', info.linkedinLink],
        ['TikTok', info.tiktokLink],
      ].filter(([, link]) => link) as [string, string][])
    : [];

  return (
    <div>
      <PageTitle title={t.about.title} />
      <RowGroup>
        <Row icon={<FileText />} title={t.about.terms} onClick={() => setTerms(true)} />
      </RowGroup>

      <SectionTitle title={t.about.contact} />
      {contact.isPending ? (
        <RowsSkeleton count={3} label={t.common.loading} />
      ) : contact.isError ? (
        <Failed message={contact.error.message} onRetry={() => contact.refetch()} t={t} />
      ) : !info ? (
        <p className="text-muted-foreground">{t.about.empty}</p>
      ) : (
        <div className="grid gap-4 lg:grid-cols-2">
          {info.emails?.length ? (
            <RowGroup>
              {info.emails.map((email) => (
                <LinkRow key={email} href={`mailto:${email}`} icon={<Mail />} title={t.about.emails} subtitle={<span dir="ltr">{email}</span>} />
              ))}
            </RowGroup>
          ) : null}
          {info.phoneNumbers?.length ? (
            <RowGroup>
              {info.phoneNumbers.map((phone) => (
                <LinkRow key={phone} href={`tel:${phone}`} icon={<Phone />} title={t.about.phones} subtitle={<span dir="ltr">{phone}</span>} />
              ))}
            </RowGroup>
          ) : null}
          {info.whatsAppNumber || info.website || social.length ? (
            <RowGroup>
              {info.whatsAppNumber ? <LinkRow blank href={`https://wa.me/${info.whatsAppNumber.replace(/\D/g, '')}`} icon={<MessageCircle />} title={t.tracking.whatsapp} subtitle={<span dir="ltr">{info.whatsAppNumber}</span>} /> : null}
              {info.website ? <LinkRow blank href={info.website} icon={<Globe />} title={t.about.title} subtitle={<span dir="ltr">{info.website}</span>} /> : null}
              {social.map(([name, link]) => (
                <LinkRow key={name} blank href={link} icon={<Share2 />} title={name} subtitle={t.about.social} />
              ))}
            </RowGroup>
          ) : null}
        </div>
      )}
      <TermsSheet t={t} open={terms} onOpenChange={setTerms} />
    </div>
  );
}
