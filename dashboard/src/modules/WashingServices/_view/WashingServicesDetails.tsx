import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';
import useSWR, { mutate as globalMutate } from 'swr';
import washingServicesService from '@services/washingServices.service';
import { IwshaingServicesList } from '@servicesTypes/wshaingServices.types';
import {
  Button,
  CityAvailability,
  FormSheet,
  InfoList,
  PageHeader,
  SectionCard,
  PageSkeleton,
} from '@UI/Index';
import { formatDate } from '@app/utils/helper';
import WashingServicesForm from '../_components/WashingServicesForm';

type Localized = string | { en?: string; ar?: string };

export default function WashingServicesDetails() {
  const [openSheet, setOpenSheet] = useState(false);
  const { washingServicesId } = useParams();
  const navigate = useNavigate();
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const local = (v?: Localized) => (typeof v === 'object' ? v?.[lang] || v?.en : v) || '';

  const swrKey = ['get-washing-services-Details', washingServicesId];
  const { data, isLoading, mutate } = useSWR(washingServicesId ? swrKey : null, () =>
    washingServicesService
      .getWashingServicesDetails(washingServicesId!)
      .then((res) => res?.data as IwshaingServicesList)
  );

  const body = (city: string) => ({ washingService: data!._id, city });
  const descriptions = (data?.description ?? [])
    .map((d) => local(d as unknown as Localized))
    .filter(Boolean);

  if (isLoading) return <PageSkeleton kind="details" />;

  return (
    <div className="space-y-5">
      <PageHeader
        onBack={() => navigate(-1)}
        leading={
          data?.icon?.iconLink && (
            <img
              src={data.icon.iconLink}
              alt=""
              className="h-10 w-10 shrink-0 rounded-full border border-border object-cover"
            />
          )
        }
        title={local(data?.name as Localized) || t('washingServicesDetails')}
        description={data && `${t('washingServicesDetails')} · #${data._id.slice(-6)}`}
        actions={
          <Button onClick={() => setOpenSheet(true)} disabled={!data}>
            {t('editServices')}
          </Button>
        }
      />

      <div className="grid gap-5 xl:grid-cols-3">
        <div className="space-y-5 xl:col-span-2">
          <SectionCard title={t('servicesInfo')}>
            <InfoList
              items={[
                { label: t('servesName'), value: local(data?.name as Localized) },
                {
                  label: t('type'),
                  value: data?.type && (
                    <span className="rounded-full bg-accent px-2.5 py-0.5 text-xs font-semibold capitalize text-primary">
                      {t(data.type)}
                    </span>
                  ),
                },
                { label: t('durationTime'), value: data && `${data.duration} ${t('min')}` },
                { label: t('price'), value: data && `${data.price} ${t('SAR')}` },
                { label: t('pointsToPay'), value: data?.pointsToPay },
                { label: t('createddate'), value: data && formatDate(data.createdAt) },
              ]}
            />
          </SectionCard>

          <SectionCard title={t('servicesDescription')}>
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
          {data && (
            <CityAvailability
              cities={data.cities as never}
              description={t('cityAvailabilityHint')}
              add={(city) => washingServicesService.addCityWashingServices(body(city))}
              activate={(city) => washingServicesService.activeCityWashingServices(body(city))}
              archive={(city) => washingServicesService.archiveCityWashingServices(body(city))}
              onChanged={() => {
                mutate();
                globalMutate(
                  (key) => Array.isArray(key) && key.includes('get-washing-services-list')
                );
              }}
            />
          )}
        </div>
      </div>

      <FormSheet
        open={openSheet}
        onOpenChange={() => setOpenSheet(false)}
        title={t('editServices')}>
        <WashingServicesForm setOpenSheet={setOpenSheet} oldData={data} />
      </FormSheet>
    </div>
  );
}
