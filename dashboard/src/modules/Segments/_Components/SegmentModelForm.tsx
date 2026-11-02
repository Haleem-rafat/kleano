import { t } from 'i18next';
import { Dispatch, SetStateAction, useState } from 'react';
import { useForm } from 'react-hook-form';
import { toast } from 'react-toastify';
import { mutate } from 'swr';

import i18n from '@app/locales/i18n';
import segmentsService from '@services/segments.service';
import { ISegment } from '@servicesTypes/segments.types';

import { Form, FormField } from '@shadecn/components/ui/form';
import { Button, MainInput, MainSelect, SheetActions, FormSkeleton } from '@UI/Index';

import { yupResolver } from '@hookform/resolvers/yup';
import useGetUsersOptions from '@/hooks/useGetUsersOptions';

interface ISegmentModelFormProps {
  setOpenSheet: Dispatch<SetStateAction<boolean>>;
  segmentData?: ISegment;
}

const SegmentModelForm = ({ setOpenSheet, segmentData }: ISegmentModelFormProps) => {
  const [loading, setLoading] = useState(false);

  const lang = i18n.language as 'en' | 'ar';
  const { usersOptions, loadingUsersOptions } = useGetUsersOptions();

  const form = useForm({
    resolver: yupResolver(segmentsService.createSegmentSchema),
    defaultValues: {
      segmentName: segmentData?.name ?? undefined,
      segmentUsers: segmentData?.users?.map((e) => ({ label: e?.userName, value: e?._id })) ?? [],
    },
  });

  const handleOnSubmitSegment = async (values) => {
    const usersId = values.segmentUsers.map((user) => user.value);
    const payload = {
      name: values.segmentName,
      users: usersId,
    };
    setLoading(true);
    const api = !segmentData
      ? segmentsService.createSegment(payload)
      : segmentsService.updateSegment(segmentData._id, payload);
    await api
      .then((data) => {
        setOpenSheet(false);
        mutate((key: string) => key.includes('get-all-segments-list'));
        mutate((key: string) => key.includes('get-segments-details'));
        toast.success('operation successfully');
        setLoading(false);
      })
      .catch(({ response }) => {
        const messages = response?.data?.message;
        const errList = Array.isArray(messages)
          ? messages.map((e, index) => <p key={index}>{e}</p>)
          : messages?.[lang] || t('An error occurred');
        toast.error(<div>{errList}</div>);
        setLoading(false);
      });
  };
  return (
    <div>
      {loadingUsersOptions && <FormSkeleton />}
      <Form {...form}>
        <form
          onSubmit={form.handleSubmit(handleOnSubmitSegment)}
          className={`flex flex-col gap-4 ${loadingUsersOptions ? 'hidden' : ''}`}>
          <FormField
            control={form.control}
            name={'segmentName'}
            render={({ field }) => (
              <MainInput
                label={t('segmentName')}
                placeholder={t('segmentName')}
                type="text"
                field={{ ...field }}
              />
            )}
          />
          <FormField
            control={form.control}
            name={'segmentUsers'}
            render={({ field }) => (
              <MainSelect
                multiSelect
                title={t('selectUserInSgment')}
                placeholder={t('selectUserInSgment')}
                options={usersOptions}
                field={{ ...field }}
              />
            )}
          />

          <SheetActions>
            <Button loading={loading} className="w-full" type="submit">
              {segmentData ? t('applyEdit') : t('add')}
            </Button>
          </SheetActions>
        </form>
      </Form>
    </div>
  );
};

export default SegmentModelForm;
