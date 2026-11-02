import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { generatePath, useNavigate, useParams } from 'react-router-dom';
import useSWR from 'swr';
import { formatDate } from '@app/utils/helper';
import { ROUTES } from '@constants/routes';
import segmentsService from '@services/segments.service';
import { ISegment } from '@servicesTypes/segments.types';
import {
  Button,
  FormSheet,
  InfoList,
  MainAvatar,
  PageHeader,
  SectionCard,
  PageSkeleton,
} from '@UI/Index';
import SegmentModelForm from '../_Components/SegmentModelForm';

const SegmentDetails = () => {
  const { t } = useTranslation();
  const [openSheet, setOpenSheet] = useState(false);
  const { segmenId } = useParams();
  const navigate = useNavigate();

  const { data, isLoading } = useSWR(segmenId ? ['get-segments-details', segmenId] : null, () =>
    segmentsService.getSegmentUsers(segmenId!).then((res) => res?.data as ISegment)
  );
  const users = data?.users ?? [];

  if (isLoading) return <PageSkeleton kind="details" />;

  return (
    <div className="space-y-5">
      <PageHeader
        onBack={() => navigate(-1)}
        title={data?.name || t('segmentsDetails')}
        description={data && `${t('segmentsDetails')} · #${data._id.slice(-6)}`}
        actions={
          <Button onClick={() => setOpenSheet(true)} disabled={!data}>
            {t('edit')}
          </Button>
        }
      />

      <div className="grid gap-5 xl:grid-cols-3">
        <div className="xl:col-span-1">
          <SectionCard title={t('segmentsInfo')}>
            <InfoList
              className="sm:grid-cols-1"
              items={[
                { label: t('segmentName'), value: data?.name },
                { label: t('createddate'), value: data?.createdAt && formatDate(data.createdAt) },
                { label: t('users'), value: users.length },
              ]}
            />
          </SectionCard>
        </div>

        <div className="xl:col-span-2">
          <SectionCard
            title={t('selectedUser')}
            action={<span className="text-xs text-muted-foreground">{users.length}</span>}>
            {users.length === 0 ? (
              <p className="py-8 text-center text-[13px] text-muted-foreground">
                {t('No users found')}
              </p>
            ) : (
              <ul className="divide-y divide-border rounded-md border border-border">
                {users.map((user) => (
                  <li key={user._id}>
                    <button
                      type="button"
                      onClick={() =>
                        navigate(generatePath(ROUTES.USERS_DETAILS, { userId: user._id }))
                      }
                      className="flex w-full items-center gap-3 px-3 py-2.5 text-start hover:bg-muted">
                      <MainAvatar src={undefined} name={user.userName} className="h-8 w-8" />
                      <div className="min-w-0">
                        <p className="truncate text-sm font-medium text-foreground">
                          {user.userName}
                        </p>
                        <p className="truncate text-xs text-muted-foreground">
                          {user.email || '—'}
                        </p>
                      </div>
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </SectionCard>
        </div>
      </div>

      <FormSheet open={openSheet} onOpenChange={() => setOpenSheet(false)} title={t('editegments')}>
        <SegmentModelForm setOpenSheet={setOpenSheet} segmentData={data} />
      </FormSheet>
    </div>
  );
};

export default SegmentDetails;
