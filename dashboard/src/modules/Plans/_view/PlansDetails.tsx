import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';
import useSWR, { mutate as globalMutate } from 'swr';
import plansService from '@services/plans.service';
import { formatDate } from '@app/utils/helper';
import {
  Button,
  CityAvailability,
  FormSheet,
  InfoList,
  PageHeader,
  SectionCard,
  PageSkeleton,
} from '@UI/Index';
import PlansModelForm from '../_Components/PlansModelForm';

type Localized = string | { en?: string; ar?: string };

export default function PlansDetails() {
  const navigate = useNavigate();
  const { plansId } = useParams();
  const [openSheet, setOpenSheet] = useState(false);
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const local = (v?: Localized) => (typeof v === 'object' ? v?.[lang] || v?.en || v?.ar : v) || '';

  const {
    data: plan,
    isLoading,
    mutate,
  } = useSWR(plansId ? ['get-all-plans-details', plansId] : null, () =>
    plansService.getAllPlansDetails(plansId!).then((res) => res.data)
  );

  const color = plan?.color ? (plan.color.startsWith('#') ? plan.color : `#${plan.color}`) : '';
  const body = (city: string) => ({ plan: plan._id, city });
  const descriptions: string[] = (plan?.description ?? []).map(local).filter(Boolean);
  const services: { _id: string; name: Localized }[] = plan?.washingServices ?? [];

  if (isLoading) return <PageSkeleton kind="details" />;

  return (
    <div className="space-y-5">
      <PageHeader
        onBack={() => navigate(-1)}
        leading={
          <span
            className="h-10 w-10 shrink-0 rounded-full border border-border"
            style={{ backgroundColor: color || undefined }}
          />
        }
        title={local(plan?.type) || t('plansDetails')}
        description={plan && `${t('plansDetails')} · #${plan._id.slice(-6)}`}
        actions={
          <Button onClick={() => setOpenSheet(true)} disabled={!plan}>
            {t('editPlan')}
          </Button>
        }
      />

      <div className="grid gap-5 xl:grid-cols-3">
        <div className="space-y-5 xl:col-span-2">
          <SectionCard title={t('planInfo')}>
            <InfoList
              items={[
                { label: t('planType'), value: local(plan?.type) },
                {
                  label: t('color'),
                  value: color && (
                    <span className="inline-flex items-center gap-2 tabular-nums">
                      <span
                        className="h-4 w-4 rounded border border-border"
                        style={{ backgroundColor: color }}
                      />
                      {color.toUpperCase()}
                    </span>
                  ),
                },
                { label: t('price'), value: plan && `${plan.price} ${t('SAR')}` },
                {
                  label: t('durationByMonth'),
                  value: plan && `${plan.duration} ${t('month')}`,
                },
                { label: t('usageCount'), value: plan?.usageCount },
                { label: t('createddate'), value: plan && formatDate(plan.createdAt) },
                {
                  label: t('icon'),
                  value: plan?.icon?.iconLink && (
                    <img
                      src={plan.icon.iconLink}
                      alt=""
                      className="h-10 w-10 rounded-md object-contain"
                    />
                  ),
                },
              ]}
            />
          </SectionCard>

          <SectionCard
            title={t('washingServicesPlan')}
            action={
              services.length > 0 && (
                <span className="text-xs text-muted-foreground">{services.length}</span>
              )
            }>
            {services.length ? (
              <div className="flex flex-wrap gap-2">
                {services.map((s) => (
                  <span
                    key={s._id}
                    className="rounded-full bg-accent px-3 py-1 text-[13px] font-medium text-primary">
                    {local(s.name)}
                  </span>
                ))}
              </div>
            ) : (
              <p className="text-[13px] text-muted-foreground">
                {t('No washing services assigned to this plan')}
              </p>
            )}
          </SectionCard>

          <SectionCard title={t('Plan Description')}>
            {descriptions.length ? (
              <ul className="space-y-2">
                {descriptions.map((text, i) => (
                  <li key={i} className="flex gap-3 text-sm text-foreground">
                    <span className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-primary" />
                    <span className="min-w-0 break-words">{text}</span>
                  </li>
                ))}
              </ul>
            ) : (
              <p className="text-[13px] text-muted-foreground">{t('noDescription')}</p>
            )}
          </SectionCard>
        </div>

        <div className="xl:col-span-1">
          {plan && (
            <CityAvailability
              cities={plan.cities}
              description={t('cityAvailabilityHint')}
              add={(city) => plansService.addCityPlan(body(city))}
              activate={(city) => plansService.activeCityPlan(body(city))}
              archive={(city) => plansService.archiveCityPlan(body(city))}
              onChanged={() => {
                mutate();
                globalMutate((key) => Array.isArray(key) && key.includes('get-all-plans-list'));
              }}
            />
          )}
        </div>
      </div>

      <FormSheet open={openSheet} onOpenChange={() => setOpenSheet(false)} title={t('editPlan')}>
        {plan && <PlansModelForm setOpenSheet={setOpenSheet} oldData={plan} />}
      </FormSheet>
    </div>
  );
}
