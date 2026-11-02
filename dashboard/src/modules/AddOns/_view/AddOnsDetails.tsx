import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';
import useSWR, { mutate as globalMutate } from 'swr';
import addOnsService from '@services/addOns.service';
import { IAddOns } from '@servicesTypes/addOns';
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
import AddOnsForm from '../_components/AddOnsForm';

type Localized = string | { en?: string; ar?: string };

export default function AddOnsDetails() {
  const navigate = useNavigate();
  const { addOnsId } = useParams();
  const [openSheet, setOpenSheet] = useState(false);
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const local = (v?: Localized) => (typeof v === 'object' ? v?.[lang] || v?.en : v) || '';

  const { data, isLoading, mutate } = useSWR(
    addOnsId ? ['get-all-add-ons-details', addOnsId] : null,
    () => addOnsService.getAddOnsDetails(addOnsId!).then((res) => res.data as IAddOns)
  );

  const body = (city: string) => ({ addOns: data!._id, city });
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const item = data as any;

  if (isLoading) return <PageSkeleton kind="details" />;

  return (
    <div className="space-y-5">
      <PageHeader
        onBack={() => navigate(-1)}
        leading={
          item?.icon?.iconLink && (
            <img
              src={item.icon.iconLink}
              alt=""
              className="h-10 w-10 shrink-0 rounded-full border border-border object-cover"
            />
          )
        }
        title={local(item?.name) || t('addOnsDetails')}
        description={item && `${t('addOnsDetails')} · #${item._id.slice(-6)}`}
        actions={
          <Button onClick={() => setOpenSheet(true)} disabled={!data}>
            {t('editAddOns')}
          </Button>
        }
      />

      <div className="grid gap-5 xl:grid-cols-3">
        <div className="xl:col-span-2">
          <SectionCard title={t('addOnsInfo')}>
            <InfoList
              items={[
                { label: t('addOnsName'), value: local(item?.name) },
                { label: t('addOnsPrice'), value: item && `${item.price} ${t('SAR')}` },
                {
                  label: t('stock'),
                  value: item && (
                    <span className={item.stock > 0 ? 'text-foreground' : 'text-destructive'}>
                      {item.stock}
                    </span>
                  ),
                },
                { label: t('createddate'), value: item?.createdAt && formatDate(item.createdAt) },
              ]}
            />
          </SectionCard>
        </div>

        <div className="xl:col-span-1">
          {item && (
            <CityAvailability
              cities={item.cities}
              description={t('cityAvailabilityHint')}
              add={(city) => addOnsService.addCityPlan(body(city))}
              activate={(city) => addOnsService.activeCityPlan(body(city))}
              archive={(city) => addOnsService.archiveCityPlan(body(city))}
              onChanged={() => {
                mutate();
                globalMutate((key) => Array.isArray(key) && key.includes('get-all-add-ons-list'));
              }}
            />
          )}
        </div>
      </div>

      <FormSheet open={openSheet} onOpenChange={() => setOpenSheet(false)} title={t('editAddOns')}>
        <AddOnsForm setOpenSheet={setOpenSheet} oldData={data} />
      </FormSheet>
    </div>
  );
}
