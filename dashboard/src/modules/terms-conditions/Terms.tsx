import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import useSWR from 'swr';
import termsService from '@services/terms.service';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@shadecn/components/ui/tabs';
import { Button, PageHeader } from '@UI/Index';
import RichTextEditor, { toEditorHtml } from '@UI/RichText/RichTextEditor';

type Lang = 'en' | 'ar';
type Content = Record<Lang, string>;

const LANGS: { key: Lang; label: string; dir: 'ltr' | 'rtl' }[] = [
  { key: 'en', label: 'English', dir: 'ltr' },
  { key: 'ar', label: 'العربية', dir: 'rtl' },
];

const textLength = (html: string) => html.replace(/<[^>]+>/g, '').trim().length;

const Terms = () => {
  const { t } = useTranslation();
  const [saved, setSaved] = useState<Content>({ en: '', ar: '' });
  const [draft, setDraft] = useState<Content>({ en: '', ar: '' });
  const [isEdit, setIsEdit] = useState(false);
  const [saving, setSaving] = useState(false);
  const [tab, setTab] = useState<Lang>('en');

  const { isLoading } = useSWR('terms', () =>
    termsService.getTerms().then((res) => {
      const content = res?.data?.content;
      const next =
        content && typeof content === 'object'
          ? { en: toEditorHtml(content.en), ar: toEditorHtml(content.ar) }
          : { en: toEditorHtml(content || ''), ar: '' };
      setSaved(next);
      setDraft(next);
      return next;
    })
  );

  const isDirty = draft.en !== saved.en || draft.ar !== saved.ar;

  // Warn before leaving the page with unsaved edits.
  useEffect(() => {
    if (!isEdit || !isDirty) return;
    const warn = (e: BeforeUnloadEvent) => e.preventDefault();
    window.addEventListener('beforeunload', warn);
    return () => window.removeEventListener('beforeunload', warn);
  }, [isEdit, isDirty]);

  const handleSave = async () => {
    const empty = LANGS.find((l) => !textLength(draft[l.key]));
    if (empty) {
      setTab(empty.key);
      toast.warning(t('termsEmpty', { lang: empty.label }));
      return;
    }
    setSaving(true);
    try {
      await termsService.updateTerms({ en: draft.en, ar: draft.ar });
      setSaved(draft);
      setIsEdit(false);
      toast.success(t('termsSaved'));
    } catch (e) {
      const msg = (e as { response?: { data?: { message?: Partial<Content> } } })?.response?.data
        ?.message;
      toast.error(msg?.en || t('somethingWentWrong'));
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
    setDraft(saved);
    setIsEdit(false);
  };

  return (
    <div className="mx-auto w-full max-w-4xl space-y-5 pb-24 sm:pb-6">
      <PageHeader
        title={t('termsAndConditions')}
        description={isEdit ? t('termsEditHint') : t('termsViewHint')}
        actions={
          isEdit ? (
            <>
              <Button variant="secondary" onClick={handleCancel} disabled={saving}>
                {t('cancel')}
              </Button>
              <Button onClick={handleSave} loading={saving} disabled={saving || !isDirty}>
                {t('save')}
              </Button>
            </>
          ) : (
            <Button onClick={() => setIsEdit(true)} disabled={isLoading}>
              {t('edit')}
            </Button>
          )
        }
      />

      <section className="rounded-lg border border-border bg-card">
        <Tabs value={tab} onValueChange={(v) => setTab(v as Lang)}>
          <div className="flex flex-wrap items-center justify-between gap-2 border-b border-border px-4 py-3 sm:px-5">
            <TabsList>
              {LANGS.map((l) => (
                <TabsTrigger key={l.key} value={l.key} className="gap-2">
                  {l.label}
                  {isEdit && draft[l.key] !== saved[l.key] && (
                    <span
                      className="h-1.5 w-1.5 rounded-full bg-warning"
                      aria-label={t('unsavedChanges')}
                    />
                  )}
                </TabsTrigger>
              ))}
            </TabsList>
            <span className="text-xs tabular-nums text-muted-foreground">
              {t('characters', { count: textLength(draft[tab]) })}
            </span>
          </div>

          {LANGS.map((l) => (
            <TabsContent key={l.key} value={l.key} className="m-0 p-4 sm:p-5">
              {isLoading ? (
                <div className="space-y-3" aria-busy>
                  {[90, 75, 85, 60].map((w) => (
                    <div
                      key={w}
                      className="h-4 animate-pulse rounded bg-muted"
                      style={{ width: `${w}%` }}
                    />
                  ))}
                </div>
              ) : isEdit ? (
                <RichTextEditor
                  value={draft[l.key]}
                  onChange={(html) => setDraft((d) => ({ ...d, [l.key]: html }))}
                  dir={l.dir}
                  placeholder={
                    l.key === 'ar'
                      ? 'اكتب الشروط والأحكام هنا…'
                      : 'Write the terms & conditions here…'
                  }
                  className="[&_.rich-text]:min-h-[50vh]"
                />
              ) : saved[l.key] ? (
                <div
                  dir={l.dir}
                  className="rich-text"
                  // Content is written by admins in the editor above.
                  dangerouslySetInnerHTML={{ __html: saved[l.key] }}
                />
              ) : (
                <p className="py-10 text-center text-sm text-muted-foreground">{t('termsNone')}</p>
              )}
            </TabsContent>
          ))}
        </Tabs>
      </section>
    </div>
  );
};

export default Terms;
